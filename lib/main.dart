import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reality_near/core/framework/colors.dart';
import 'package:reality_near/core/framework/globals.dart';
import 'package:reality_near/generated/l10n.dart';
import 'package:reality_near/presentation/bloc/menu/menu_bloc.dart';
import 'package:reality_near/presentation/bloc/socket/chat_service.dart';
import 'package:reality_near/presentation/bloc/user/user_bloc.dart';
import 'package:reality_near/presentation/bloc/socket/socket_service.dart';
import 'package:reality_near/core/routes.dart';
import 'package:reality_near/presentation/views/firstScreen/firstScreen.dart';
import 'package:reality_near/presentation/views/homeScreen/homeScreen.dart';
import 'package:reality_near/presentation/views/mapScreen/widgets/map.dart';
import 'package:reality_near/providers/location_provider.dart';
import 'package:showcaseview/showcaseview.dart';

bool isLoggedIn;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    isLoggedIn = await getPersistData('userToken') != null;
    print('isLoggedIn: $isLoggedIn');
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SocketService().connect();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => MenuBloc()),
      ],
      child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => LocationProvider(),
              child: const MapSection(),
            ),
            ChangeNotifierProvider(create: (_) => SocketService()),
            ChangeNotifierProvider(create: (_) => ChatService()),
          ],
          child: ShowCaseWidget(
            onFinish: () => persistData('passInitGuide', 'true'),
            builder: Builder(
              builder: (context) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Reality Near',
                  //Tema Principal, se usa cuando no está activo el modo oscuro
                  theme: ThemeData(
                    //Se indica que el tema tiene un brillo luminoso/claro
                    brightness: Brightness.light,
                    primarySwatch: Palette.kgreenNR,
                  ),
                  //Tema Oscuro, se usa cuando se activa el modo oscuro
                  // darkTheme: ThemeData(
                  //   //Se indica que el tema tiene un brillo oscuro
                  //   brightness: Brightness.dark,
                  //   scaffoldBackgroundColor: Colors.black,
                  //   backgroundColor: Colors.black,
                  //   primarySwatch: Palette.kgreenNR,
                  // ),
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  initialRoute:
                      isLoggedIn ? HomeScreen.routeName : FirstScreen.routeName,
                  // initialRoute:"/qrViewScreen",
                  routes: routes,
                );
              },
            ),
          )),
    );
  }
}
