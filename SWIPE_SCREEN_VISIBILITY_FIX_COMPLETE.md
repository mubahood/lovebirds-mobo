Make sure the following changes are made to the app to improve user experience and functionality: If necessary to modify the backend api or database, please ensure that the changes are implemented accordingly BUT NOT TO BREAK already existing functionality.
### Onboarding Screens
- [ ] Design onboarding screens to be visually appealing, modern, and intuitive.
- [ ] Use a clean layout with engaging graphics and concise text to guide new users.
- [ ] Ensure navigation is straightforward, with clear progress indicators and easy-to-understand steps.
- [ ] Include prominent and accessible calls to action for both sign up and log in.
- [ ] Display onboarding screens only for users who are not authenticated.
- [ ] Once a user logs in, skip onboarding screens on subsequent app launches.
- [ ] Leverage recommended Flutter packages (e\.g\., `introduction_screen`, `smooth_page_indicator`) to enhance onboarding visuals and interactivity.
- [ ] 
### Home Screen Improvements
- [ ] When tapping the fire icon for boosting, the pop-up should take the user to the subscription page after pressing the boost button, instead of just displaying "you need opremium...".
- [ ] The app should be simple to use: remove unnecessary buttons such as purchase boost, upgrade premium, etc. There should be only one button that leads to the subscription page.

### User Profile Page Redesign
- [ ] Redesign the user profile details page to be more user-friendly and visually appealing.
- [ ] Display all information collected in the profile form in a well-organized and attractive manner.
- [ ] The profile page should be simple to use and include a button that leads to the subscription page.
- [ ] Display a gallery of the user's photos. on user profile page.
- [ ] Allow the user to add photos from the gallery.
- [ ] Allow the user to delete photos from the gallery.
- [ ] Allow the user to change the profile photo.
- [ ] Allow the user to change their name.
- [ ] Include a "You May Also Like" section to show other related profiles of other users.
- [ ] Allow the user to view the profile of:
  - [ ] People who liked them
  - [ ] People they liked
  - [ ] People they matched with
  - [ ] People they chatted with
  - [ ] People they blocked
  - [ ] People they reported
- [ ] PLEAS Make the app extremely simple to use, with no unnecessary buttons or restrictions.
- [ ] FOR EXAMPLE, A USER DOES NOT NEED TO BE MATCHED IN ORDER TO CHAT WITH SOMEONE. THEY SHOULD BE ABLE TO CHAT WITH ANYONE THEY LIKE, REGARDLESS OF MATCH STATUS. PLEASE REMOVE ALL SUCH KIND OF RESTRICTIONS.
### My Matches Page
- [ ] Redesign the "My Matches" page to be more user-friendly and visually appealing and not crashing the screen.
- [ ] My matches is failing to show images , it s showing only persons initials instead of their images. Please fix this issue. 
- [ ] The top tab pills are too huge, they should be smaller and more compact and nice looking.
- [ ] You must make use of CachedNetworkImage image to show the images in the WHOLE app, not just in the matches page.

### Chat Page
- [ ] The message is not actually sent. it shows failed. please test the api very well and make sure it works. most especially when starting a new chat.
- [ ] Make sure you use The http_post and http_get methods in the Utils class to make all kinds of api calls in the whole app.
- [ ] The chat has to send a text, image, video, audio, and location. BUT NOW IT IS SENDING ONLY TEXT. PLEASE CAREFULLY IMPLEMENT THESE FEATURES. If not not in backend go ahead and add them to the backend api. 
- [ ] The chat should be able to send and receive images, videos, audio files, and location.
- [ ] Make use of any fluter package that can help you implement the above features.