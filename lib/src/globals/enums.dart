// AUTH
enum AuthType { mobile, email }
enum AuthStatus { notAuth, auth, linkSent, smsSent, isLoading, error }
// NAV
enum Nav { auth, profile, home, chat }
// CONNECTION
enum FriendStatus { open, sent, received, friend }
enum FriendAction { send, accept, decline, remove }
// INVITE

// CHAT
enum MessageType { text, image, url } // do text first //
// ERRORS
enum BlocError {
  authDynamicLink,
  authMobileFail,
  authEmailFail,
  authInitEmail,
  authInitMobile,
  updateUser,
  userGlobalAlertToggle,
  userAddChatAlert,
  userRemoveChatAlert,
  userAddGlobalChatAlert,
  userRemoveGlobalChatAlert,
  createUser,
  friendInvite,
  friendAccept,
  friendRemove,
  friendDecline,
  chatCreateGlobalChatMessage,
  chatGlobalChat,
  chatGlobalChatMessage,
  chatCreateChatMessage,
  chatCreate,
  chatChatMessage
}
