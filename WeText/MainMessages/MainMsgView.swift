//
//  MainMsgView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 14/12/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestoreSwift
import Firebase

class MainMessagesViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false

    init() {
            DispatchQueue.main.async {
                self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            
            }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessageArray = [RecentMessage]()
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        firestoreListener?.remove()
        self.recentMessageArray.removeAll()
        
        
        firestoreListener =  FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener{ querySnapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to listen to recent message \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({
                    change in
                        let docId = change.document.documentID
                        if let index = self.recentMessageArray.firstIndex(where: {rm in
                            return rm.id == docId
                        })
                        {
                            self.recentMessageArray.remove(at: index)
                        }
                    do{
                        if let rm = try change.document.data(as: RecentMessage.self){
                            self.recentMessageArray.insert(rm, at: 0)
                        }
                    } catch{
                        print(error)
                    }
                    //                        self.recentMessageArray.insert(.init(documentId: docId, data: change.document.data()), at: 0)
//                        self.recentMessageArray.append()
                })
            }
    }
    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return

            }
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isCurrentlyLoggedOut = false
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
                 try? FirebaseManager.shared.auth.signOut()
    }

}

struct MainMsgView: View {
    
    @ObservedObject var vm = MainMessagesViewModel()
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    private var chatLogViewModel1 = ChatLogViewModel(chatUser: nil)

    var body: some View {
        NavigationView{
            VStack{
                customNavBar
                ScrollView{
                    VStack{
                        ForEach (vm.recentMessageArray){ recentMessage in
                            Button {
                                let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                                
                                self.chatUser = .init(data:[FirebaseConstants.email : recentMessage.email, FirebaseConstants.uName : recentMessage.uName, FirebaseConstants.profileImageUrl : recentMessage.profileImageUrl, FirebaseConstants.uid : uid])
                                self.chatLogViewModel1.chatUser = self.chatUser
                                self.chatLogViewModel1.fetchMessages()
                                self.shouldNavigateToChatLogView.toggle()
                        } label: {
                            HStack{
                                WebImage(url: URL(string: recentMessage.profileImageUrl))
                                    .resizable()
                                    .scaledToFill().frame(width: 64, height: 64)
                                    .clipped()
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(.primary, lineWidth: 2))
                                VStack(alignment: .leading){
                                    Text(recentMessage.uName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(.label))
                                    Text(recentMessage.text)
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.leading)
                                        
                                }
                                Spacer()
                                Text(recentMessage.timeAgo)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        Divider()
                            .padding(.vertical,8)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom,50)
            }
                NavigationLink("", isActive: $shouldNavigateToChatLogView){
                    
                    ChatLogView(vm: chatLogViewModel1)
                    
                }
            }
            .overlay(newMessageButton,alignment: .bottom)
            .navigationBarHidden(true)
            
        }
    }
    private var customNavBar: some View{
        VStack{
            HStack{
                    Text("WeText")
                        .multilineTextAlignment(.leading)
                        .padding(.trailing)
                        .foregroundColor(Color("NavBarText"))
                        .padding(.horizontal,20)
                        .padding(.vertical, 20)
        }
            
                .font(.system(size: 30, weight: .heavy))
                .frame(maxWidth: .infinity,maxHeight: 45.0, alignment: .leading)

                .background(Color("NavBarColor"))
            HStack(spacing: 16){
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 70)
                    .clipped()
                    .cornerRadius(44)
                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(.primary, lineWidth: 3))
                    .shadow(color: Color(.darkGray) , radius: 10)
                
                VStack(alignment: .leading, spacing: 2){
                    
                    //Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
                     Text(vm.chatUser?.uName ?? "")
                        .font(.system(size: 28, weight: .semibold))
                    HStack{
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 14, height: 12, alignment: .leading)
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                Button {
                    shouldShowLogOutOptions.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.label))
                    }
            }.padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("Do you want to switch Accounts?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("signing out")
                        vm.handleSignOut()
                    }),
                        .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(loginComplete: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.fetchRecentMessages()
                }
            )}
        }
    }
    
    @State var newMsgScreen = false
    
    private var newMessageButton: some View{
        Button {
                newMsgScreen.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 20, weight: .bold))
                        Spacer()
                    }
                .foregroundColor(.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(radius: 16)
            }
//            .alignmentGuide(.trailing)
            .fullScreenCover(isPresented: $newMsgScreen, onDismiss: nil){
                NewMessageView(selectNewUser: { user in
                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                    self.chatLogViewModel1.chatUser = user
                    self.chatLogViewModel1.fetchMessages()
            })
        }
        
    }
        @State var chatUser: ChatUser?
}


struct MainMsgView_Previews: PreviewProvider {
    static var previews: some View {
        MainMsgView()
            .preferredColorScheme(.dark)
    }
}
