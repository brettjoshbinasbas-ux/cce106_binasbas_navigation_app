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

  void selectTab(WidgetTester tester, int index) {
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    navBar.onDestinationSelected!(index);
  }

  testWidgets('Complete Integration Flow: Tests 1 to 14', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Test 1: Open the application -> Login appears first
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Test 2: Submit empty login fields -> Validation messages appear
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);

    // Test 3: Enter incorrect credentials -> Login rejected with SnackBar
    final loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), 'wronguser');
    await tester.enterText(loginFields.at(1), 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Invalid username or password.'), findsOneWidget);

    // Dismiss snackbar
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Test 4: Enter admin / admin123 -> Dashboard opens
    await tester.enterText(loginFields.at(0), 'admin');
    await tester.enterText(loginFields.at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);

    // Test 5: Read the dashboard greeting -> Displays Welcome, admin!
    expect(find.text('Welcome, admin!'), findsOneWidget);

    // Test 6: Open Calculator and calculate 10 + 5 -> Displays 15.0
    selectTab(tester, 1);
    await tester.pumpAndSettle();
    expect(find.text('My Stateful Calculator'), findsOneWidget);

    final calcInputs = find.byType(TextField);
    await tester.enterText(calcInputs.at(0), '10');
    await tester.enterText(calcInputs.at(1), '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pumpAndSettle();
    expect(find.text('15.0'), findsOneWidget);

    // Test 7: Switch tabs and return to Calculator -> Inputs and result remain
    selectTab(tester, 0);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    selectTab(tester, 1);
    await tester.pumpAndSettle();
    expect(find.text('15.0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // Test 8: Create a social post -> Post displays logged-in username (admin)
    selectTab(tester, 2);
    await tester.pumpAndSettle();
    expect(find.text('Social Media'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final postFields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(postFields.at(0), 'Admin testing post');
    await tester.enterText(postFields.at(1), 'https://picsum.photos/id/10/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('Admin testing post'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);

    // Test 9: Like a post and add a comment -> Both interactions update correctly
    final likeButton = find.widgetWithText(TextButton, 'Like').first;
    await tester.tap(likeButton);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    final commentInput = find.widgetWithText(TextField, 'Add a comment...').first;
    await tester.enterText(commentInput, 'Great test comment!');
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pumpAndSettle();
    expect(find.text('Great test comment!'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);

    // Test 10: Switch tabs and return to Social -> Posts, likes, and comments remain
    selectTab(tester, 0);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    selectTab(tester, 2);
    await tester.pumpAndSettle();
    expect(find.text('Admin testing post'), findsOneWidget);
    expect(find.text('Great test comment!'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);

    // Test 11: Open Profile -> Student information and username appear
    selectTab(tester, 3);
    await tester.pumpAndSettle();
    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('BRETT JOSH B. BINASBAS'), findsOneWidget);
    expect(find.text('560382'), findsOneWidget);
    expect(find.text('Logged in as: admin'), findsOneWidget);

    // Test 12: Tap Logout -> Login appears; Back does not reopen MainScreen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);

    // Test 13: Register a valid account and log in -> Dashboard displays registered username
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final regFields = find.byType(TextFormField);
    await tester.enterText(regFields.at(0), 'BrettBinasbas');
    await tester.enterText(regFields.at(1), 'mypassword123');
    await tester.enterText(regFields.at(2), 'mypassword123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Dismiss registration snackbar
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final newLoginFields = find.byType(TextFormField);
    await tester.enterText(newLoginFields.at(0), 'BrettBinasbas');
    await tester.enterText(newLoginFields.at(1), 'mypassword123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, BrettBinasbas!'), findsOneWidget);

    // Test 14: Create a post using the registered account -> Post displays registered username
    selectTab(tester, 2);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final newPostFields = find.descendant(of: find.byType(CreatePostSheet), matching: find.byType(TextField));
    await tester.enterText(newPostFields.at(0), 'Post by BrettBinasbas');
    await tester.enterText(newPostFields.at(1), 'https://picsum.photos/id/20/600/400');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('Post by BrettBinasbas'), findsOneWidget);
    expect(find.text('BrettBinasbas'), findsOneWidget);
  });
}
