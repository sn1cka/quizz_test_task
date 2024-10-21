# Quizz Test Task


The project is based on template of # Sizzle Starter
Sizzle is a template for Flutter projects with a focus on simplicity, scalability and testability. It features a solid layered architecture, efficient dependencies management, set of useful utilities and a bunch of other goodies.

For documentation and more details, please visit [sizzle.lazebny.io](https://sizzle.lazebny.io).


# Steps to run
1. Install FVM 
2. Activate 3.24.3 flutter version by running 'fvm use 3.24.3'
3. run 'fvm flutter pub get' 
4. Generate files using 'fvm flutter run build_runner --delete conflicting outputs'
5. Run application



# Core functionalities 
[GameBloc] in game logic
[TriviaRepositoryImpl] retrieving and caching categories and questions
[GameManagerBloc] Management of selected categories 
[QuizConfig] Cacheble settings for application (amount of questions, difficulty, questiontype)
[AppDatabase] database for storaging models


# Compatability

Application was tested on Iphone 13 Pro Max, Ios Simulator (17.2, Iphone 15 Pro Max) and Anidroid API32 emulator 