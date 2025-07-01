lib/
├── main.dart
├── app/
│   ├── app.dart              # App root with routing
│   └── router.dart           # Named routes config
├── features/
│   ├── user/
│   │   ├── view/user_page.dart
│   │   ├── bloc/user_bloc.dart
│   │   ├── widgets/
│   │   │   └── camera_view.dart
│   │   └── services/
│   │       └── camera_service.dart
│   ├── navigator/
│   │   ├── view/navigator_page.dart
│   │   ├── bloc/navigator_bloc.dart
│   │   ├── widgets/
│   │   │   └── drawing_canvas.dart
│   │   └── services/
│   │       └── drawing_service.dart
│   └── shared/
│       ├── services/
│       │   └── webrtc_service.dart
│       ├── models/
│       │   └── shared_models.dart
│       └── widgets/
│           └── shared_ui.dart
├── utils/
│   ├── constants.dart
│   └── helpers.dart
└── bootstrap.dart           # App bootstrap logic



understand annotation like navigator wants to point out something in 3d plane to show in user's camera
now i want to implement 3d annotations to send from navigator to user using AR kit or any other you know but easy so implement that in this code  i shared navigator and user page with socket services so give me code without an error of implementing 3d annotations (like navigator is pointing out something but in 3D) by the navigator to sent to user.  and when user moves the camera the annotation shold be there on the object that navigator wants to point out  and dont give me too much long code i want a simple code just 3d annotations sending from navigator to user only vwery simple implementation just give me very simple code not too much complex. give me short code.




pose matrix
hit testing





# Project

I want to make a flutter app in my macOS so it contains following functionalities..
So in ui part I want to make only 2 buttons 1. User and 2. Navigator 
And save the solved problem by navigator so if user stuck again in the same problem so he can refer from there. 
1. When user will be clicked:
- It opens a camera and makes it live camera view to the person who was clicked navigator. So there constraint is navigator should be there if there is no one clicked on navigator button then just popup that there is no navigator available please wait a while.

2 When navigator clicked: 
- So it can see the live camera which user have recording to it is live sharing from user to navigator screen 
- After that navigator has ability to draw in 3D something in the screen and arrow option is also there so point out the thing.
- Now the 3D drawing from the navigator is shown to user that navigator is something drawn here.
- And the drawing is should be like in depth like 3d may be, so when user move the camera the point which is done by navigator is should be there on the object where he was pointing out.

So first give me the folder structure of the project and tell me how to make it and it is not that much big project so first give the code as per folder structure after that if I found some error I will tell you to solve.
And is that possible to make that kind of app in flutter then give me the perfect file organization which use by industry nowadays.

Give me very simple and basic code designing is not needed so just simple code which run all the functionality and also simple drawing like just one marker is needed so make it simpler and give me simple code so if I want to update then I will tell you.

now i want is that by seeing the camera of user aid can able to make drawing by using brush in the screen and that will appear to user in 3D manner so this is the basic idea if user stuck in problem he nedd help from aid so how aid will know by only from his screen that the distance from user to the object for he need help is that much far away?? so use logic and give me code which the capable that aid can draw in 3d and it is sharing to user via socket in 3d and user also can see that iin 3d world so give me that kind of code without any error and make sure data is transfering properly and user also see it in his camera properly

want to run ipad as a user and my mac's chrome as a aid. so give me code accordingly.

give me downloadable zip file of full written code. implement all these functionalities in code and give me zip file 