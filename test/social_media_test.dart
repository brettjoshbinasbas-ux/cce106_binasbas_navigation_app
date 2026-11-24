import 'package:binasbas_navigation_app/demo_auth.dart';
import 'package:binasbas_navigation_app/main.dart';
import 'package:binasbas_navigation_app/social_media/create_post_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    DemoAuth.logout();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
  });

  Future<void> loginAsAdmin(WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  void selectTab(WidgetTester tester, int index) {
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    navBar.onDestinationSelected!(index);
  }

  testWidgets('Test 1 & 2: Log in using admin account and verify sample posts appear on Social Media', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await loginAsAdmin(tester);
    expect(find.text('Welcome, admin!'), findsOneWidget);

    selectTab(tester, 2);
    await tester.pumpAndSettle();

    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('JaneSmith'), findsOneWidget);
    expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
    expect(find.text('Just finished a great book!'), findsOneWidget);
  });

  testWidgets('Test 3: Submit a post with empty fields shows validation message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await loginAsAdmin(tester);
    selectTab(tester, 2);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();

    expect(find.text('Complete both fields before submitting!'), findsOneWidget);
  });

  testWidgets('Test 4: Submit a post with invalid URL shows URL validation message', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await loginAsAdmin(tester);
    selectTab(tester, 2);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(fields.at(0), 'Test Caption');
    await tester.enterText(fields.at(1), 'invalid-url');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pump();

    expect(find.text('Enter a valid HTTP or HTTPS image URL.'), findsOneWidget);
  });

  testWidgets('Test 5 to 10: Create post, Like/Unlike, Comments, and Tab State preservation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await loginAsAdmin(tester);
    selectTab(tester, 2);
    await tester.pumpAndSettle();

    // 5. Submit valid post
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(fields.at(0), 'My first Flutter social media post!');
    await tester.enterText(fields.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('My first Flutter social media post!'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);

    // 6. Tap Like twice on the first post
    final likeButton = find.widgetWithText(TextButton, 'Like').first;
    await tester.tap(likeButton);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    final likedButton = find.widgetWithText(TextButton, 'Liked').first;
    await tester.tap(likedButton);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsNothing);

    // Like again so it remains liked
    await tester.tap(find.widgetWithText(TextButton, 'Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    // 7. Add nonempty comment
    final commentField = find.widgetWithText(TextField, 'Add a comment...').first;
    await tester.enterText(commentField, 'Awesome post!');
    final sendButton = find.byIcon(Icons.send).first;
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('Awesome post!'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);

    // 8. Submit blank comment
    await tester.enterText(commentField, '   ');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.text('1 Comments'), findsOneWidget);

    // 9. Like sample post, then create another post
    final secondPostLike = find.widgetWithText(TextButton, 'Like').first;
    await tester.tap(secondPostLike);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsNWidgets(2));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final newFields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(newFields.at(0), 'Second post here');
    await tester.enterText(newFields.at(1), 'https://picsum.photos/id/25/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    // Verify original post kept liked state and comment
    expect(find.text('Second post here'), findsOneWidget);
    expect(find.text('Awesome post!'), findsOneWidget);
    expect(find.text('Liked'), findsNWidgets(2));

    // 10. Switch tabs and return
    selectTab(tester, 0);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    selectTab(tester, 2);
    await tester.pumpAndSettle();
    expect(find.text('Second post here'), findsOneWidget);
    expect(find.text('Awesome post!'), findsOneWidget);
    expect(find.text('Liked'), findsNWidgets(2));
  });

  testWidgets('Test 11: Logout, register new user, and verify posts show new username', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await loginAsAdmin(tester);
    selectTab(tester, 3);
    await tester.pumpAndSettle();

    // Logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);

    // Register
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final regFields = find.byType(TextFormField);
    await tester.enterText(regFields.at(0), 'StudentUser');
    await tester.enterText(regFields.at(1), 'password123');
    await tester.enterText(regFields.at(2), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Dismiss registration snackbar before continuing
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Login as StudentUser
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'StudentUser');
    await tester.enterText(loginFields.at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Go to Social Media (index 2)
    selectTab(tester, 2);
    await tester.pumpAndSettle();

    // Create post
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final fields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(fields.at(0), 'Post from StudentUser');
    await tester.enterText(fields.at(1), 'https://picsum.photos/id/40/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('Post from StudentUser'), findsOneWidget);
    expect(find.text('StudentUser'), findsOneWidget);
  });
}
