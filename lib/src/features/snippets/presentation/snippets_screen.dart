import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain
// ─────────────────────────────────────────────────────────────────────────────

class Snippet {
  const Snippet({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.code,
  });
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String code;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data — 40+ curated snippets
// ─────────────────────────────────────────────────────────────────────────────

const _allSnippets = <Snippet>[
  // ── State Management ──────────────────────────────────────────────────────
  Snippet(
    id: 'riverpod_notifier',
    title: 'Riverpod Notifier',
    category: 'State',
    tags: ['riverpod', 'notifier', 'state'],
    description: 'A typed AsyncNotifier with build_runner annotation.',
    code: '''import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_notifier.g.dart';

@riverpod
class MyNotifier extends _\$MyNotifier {
  @override
  Future<List<String>> build() async {
    return await _fetchData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchData);
  }

  Future<List<String>> _fetchData() async {
    // TODO: implement
    return [];
  }
}''',
  ),
  Snippet(
    id: 'riverpod_consumer',
    title: 'ConsumerWidget Pattern',
    category: 'State',
    tags: ['riverpod', 'consumer', 'widget'],
    description: 'Watch an AsyncNotifier and handle loading/error/data states.',
    code: '''class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(myNotifierProvider);

    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: \$e')),
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => ListTile(title: Text(items[i])),
      ),
    );
  }
}''',
  ),
  Snippet(
    id: 'riverpod_family',
    title: 'Riverpod Family Provider',
    category: 'State',
    tags: ['riverpod', 'family', 'parameter'],
    description: 'Parameterized provider using .family modifier.',
    code: '''@riverpod
Future<User> userById(UserByIdRef ref, String userId) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.fetchUser(userId);
}

// Usage in widget:
// final user = ref.watch(userByIdProvider('user-123'));''',
  ),
  Snippet(
    id: 'bloc_cubit',
    title: 'Bloc Cubit Pattern',
    category: 'State',
    tags: ['bloc', 'cubit', 'state'],
    description: 'Simple Cubit with sealed state class.',
    code: '''// State
sealed class CounterState {
  const CounterState();
}
class CounterInitial extends CounterState {}
class CounterLoaded extends CounterState {
  const CounterLoaded(this.count);
  final int count;
}

// Cubit
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitial());

  void increment() {
    final current = state is CounterLoaded
        ? (state as CounterLoaded).count
        : 0;
    emit(CounterLoaded(current + 1));
  }
}

// Widget
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) {
    if (state is CounterLoaded) {
      return Text('\${state.count}');
    }
    return const Text('0');
  },
)''',
  ),

  // ── Navigation ────────────────────────────────────────────────────────────
  Snippet(
    id: 'go_router_setup',
    title: 'GoRouter Setup',
    category: 'Navigation',
    tags: ['go_router', 'routing', 'navigation'],
    description: 'Complete GoRouter configuration with typed routes.',
    code: '''import 'package:go_router/go_router.dart';

enum AppRoute { home, detail }

final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: AppRoute.home.name,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          name: AppRoute.detail.name,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

// Navigate:
// context.goNamed(AppRoute.detail.name, pathParameters: {'id': '42'});''',
  ),
  Snippet(
    id: 'go_router_redirect',
    title: 'GoRouter Auth Redirect',
    category: 'Navigation',
    tags: ['go_router', 'redirect', 'auth'],
    description: 'Redirect unauthenticated users to login screen.',
    code: '''final goRouter = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isOnLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLoginPage) return '/login';
    if (isLoggedIn && isOnLoginPage) return '/';
    return null; // no redirect
  },
  routes: [/* ... */],
);''',
  ),
  Snippet(
    id: 'bottom_nav',
    title: 'Persistent Bottom Nav',
    category: 'Navigation',
    tags: ['navigation', 'bottom_nav', 'shell_route'],
    description: 'ShellRoute for persistent bottom navigation bar.',
    code: '''ShellRoute(
  builder: (context, state, child) => ScaffoldWithNavBar(child: child),
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomeTab()),
    GoRoute(path: '/search', builder: (_, __) => const SearchTab()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileTab()),
  ],
),

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/search');
            case 2: context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}''',
  ),

  // ── UI Patterns ───────────────────────────────────────────────────────────
  Snippet(
    id: 'shimmer_loading',
    title: 'Shimmer Loading Effect',
    category: 'UI Patterns',
    tags: ['shimmer', 'loading', 'skeleton'],
    description: 'Animated shimmer skeleton without any package.',
    code: '''class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });
  final double width, height, radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [Color(0xFF1A1A1A), Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          ),
        ),
      ),
    );
  }
}''',
  ),
  Snippet(
    id: 'pull_to_refresh',
    title: 'Pull to Refresh',
    category: 'UI Patterns',
    tags: ['refresh', 'list', 'scroll'],
    description: 'RefreshIndicator with Riverpod state invalidation.',
    code: '''class RefreshableList extends ConsumerWidget {
  const RefreshableList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(itemsProvider);
        await ref.read(itemsProvider.future);
      },
      child: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: \$e')),
        data: (list) => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (_, i) => ListTile(title: Text(list[i])),
        ),
      ),
    );
  }
}''',
  ),
  Snippet(
    id: 'infinite_scroll',
    title: 'Infinite Scroll List',
    category: 'UI Patterns',
    tags: ['pagination', 'infinite', 'scroll'],
    description: 'Load more items when user scrolls to the bottom.',
    code: '''class InfiniteList extends StatefulWidget {
  const InfiniteList({super.key});

  @override
  State<InfiniteList> createState() => _InfiniteListState();
}

class _InfiniteListState extends State<InfiniteList> {
  final _scrollCtrl = ScrollController();
  final _items = <String>[];
  bool _loading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _items.addAll(List.generate(20, (i) => 'Item \${(_page - 1) * 20 + i + 1}'));
      _page++;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollCtrl,
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(title: Text(_items[i]));
      },
    );
  }
}''',
  ),
  Snippet(
    id: 'responsive_layout',
    title: 'Responsive Layout Builder',
    category: 'UI Patterns',
    tags: ['responsive', 'adaptive', 'layout'],
    description: 'Breakpoint-based layout that adapts to screen size.',
    code: '''class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) return desktop;
        if (constraints.maxWidth >= 600) return tablet ?? desktop;
        return mobile;
      },
    );
  }
}

// Usage:
// ResponsiveLayout(
//   mobile: const MobileView(),
//   desktop: const DesktopView(),
// )''',
  ),
  Snippet(
    id: 'animated_switcher',
    title: 'Animated Content Switcher',
    category: 'UI Patterns',
    tags: ['animation', 'transition', 'switcher'],
    description: 'Fade/scale transition when content changes.',
    code: '''AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
      child: child,
    ),
  ),
  child: Container(
    key: ValueKey(_currentPage), // ← key must change to trigger animation
    child: _buildPage(_currentPage),
  ),
)''',
  ),
  Snippet(
    id: 'hero_animation',
    title: 'Hero Animation',
    category: 'UI Patterns',
    tags: ['hero', 'animation', 'transition'],
    description: 'Shared element transition between two screens.',
    code: '''// Screen A
GestureDetector(
  onTap: () => context.push('/detail/\${item.id}'),
  child: Hero(
    tag: 'item-image-\${item.id}',
    child: Image.network(item.imageUrl, width: 80, height: 80),
  ),
),

// Screen B
Hero(
  tag: 'item-image-\${widget.id}',
  child: Image.network(item.imageUrl, width: double.infinity),
)''',
  ),
  Snippet(
    id: 'custom_painter',
    title: 'Custom Painter',
    category: 'UI Patterns',
    tags: ['canvas', 'painter', 'drawing'],
    description: 'Custom drawing with Canvas — a gradient arc progress ring.',
    code: '''class ArcProgressPainter extends CustomPainter {
  const ArcProgressPainter({required this.progress, required this.color});
  final double progress; // 0.0 to 1.0
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = 8,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ArcProgressPainter old) =>
      old.progress != progress || old.color != color;
}

// Usage:
// CustomPaint(
//   painter: ArcProgressPainter(progress: 0.7, color: Colors.blue),
//   child: const SizedBox(width: 80, height: 80),
// )''',
  ),

  // ── Networking ────────────────────────────────────────────────────────────
  Snippet(
    id: 'dio_setup',
    title: 'Dio HTTP Client Setup',
    category: 'Networking',
    tags: ['dio', 'http', 'api'],
    description: 'Dio client with base URL, timeout, and auth interceptor.',
    code: '''class ApiClient {
  ApiClient({required String baseUrl, required String Function() getToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      // Auth token injection
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer \${getToken()}';
          handler.next(options);
        },
      ),
      // Logging in debug
      if (kDebugMode) LogInterceptor(responseBody: true),
    ]);
  }

  late final Dio _dio;

  Future<T> get<T>(String path, T Function(dynamic) fromJson) async {
    final response = await _dio.get(path);
    return fromJson(response.data);
  }

  Future<T> post<T>(String path, dynamic body, T Function(dynamic) fromJson) async {
    final response = await _dio.post(path, data: body);
    return fromJson(response.data);
  }
}''',
  ),
  Snippet(
    id: 'result_type',
    title: 'Result<T> Type',
    category: 'Networking',
    tags: ['result', 'error_handling', 'sealed'],
    description:
        'Sealed Result type for safe API responses without exceptions.',
    code: '''sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}

// Repository usage:
Future<Result<User>> fetchUser(String id) async {
  try {
    final data = await api.get('/users/\$id');
    return Success(User.fromJson(data));
  } catch (e, st) {
    return Failure(e, st);
  }
}

// Widget usage:
final result = await ref.read(userRepoProvider).fetchUser(id);
switch (result) {
  case Success(:final data): showUser(data);
  case Failure(:final error): showError(error);
}''',
  ),

  // ── Forms & Validation ────────────────────────────────────────────────────
  Snippet(
    id: 'form_validation',
    title: 'Form Validation',
    category: 'Forms',
    tags: ['form', 'validation', 'textfield'],
    description: 'Full form validation with GlobalKey and validators.',
    code: '''class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Form is valid — proceed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!RegExp(r\\'^[\\w.]+@[\\w]+\\.[\\w]+\$\\').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) {
              if (v == null || v.length < 8) return 'Min 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _submit, child: const Text('Login')),
        ],
      ),
    );
  }
}''',
  ),

  // ── Storage ───────────────────────────────────────────────────────────────
  Snippet(
    id: 'shared_prefs',
    title: 'SharedPreferences Service',
    category: 'Storage',
    tags: ['storage', 'prefs', 'local'],
    description: 'Type-safe wrapper around SharedPreferences.',
    code: '''class PrefsService {
  PrefsService(this._prefs);
  final SharedPreferences _prefs;

  // Theme
  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  set isDarkMode(bool v) => _prefs.setBool('dark_mode', v);

  // Auth
  String? get authToken => _prefs.getString('auth_token');
  set authToken(String? v) =>
      v == null ? _prefs.remove('auth_token') : _prefs.setString('auth_token', v);

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool('onboarding_done') ?? false;
  Future<void> markOnboardingDone() => _prefs.setBool('onboarding_done', true);
}

// Riverpod provider:
@riverpod
Future<PrefsService> prefsService(PrefsServiceRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return PrefsService(prefs);
}''',
  ),

  // ── Platform & Utils ──────────────────────────────────────────────────────
  Snippet(
    id: 'platform_check',
    title: 'Platform Checks',
    category: 'Platform',
    tags: ['platform', 'web', 'mobile', 'desktop'],
    description: 'Utility class for runtime platform detection.',
    code: '''import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppPlatform {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}

// Usage:
// if (AppPlatform.isMobile) showBottomSheet();
// if (AppPlatform.isDesktop) showSidePanel();''',
  ),
  Snippet(
    id: 'env_config',
    title: 'Environment Config',
    category: 'Platform',
    tags: ['env', 'config', 'dart-define'],
    description: 'Type-safe config from --dart-define (3 environments).',
    code: '''abstract class AppConfig {
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-dev.example.com',
  );
  static const enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';
}

// Run with:
// flutter run --dart-define=ENVIRONMENT=prod --dart-define=API_BASE_URL=https://api.example.com''',
  ),
  Snippet(
    id: 'extensions',
    title: 'Useful Dart Extensions',
    category: 'Utils',
    tags: ['extensions', 'dart', 'utility'],
    description: 'Context, String, and List extension methods.',
    code: '''extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  bool get isMobile => screenSize.width < 600;
  void showSnack(String msg) => ScaffoldMessenger.of(this)
      .showSnackBar(SnackBar(content: Text(msg)));
}

extension StringX on String {
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? '' : \${w[0].toUpperCase()}\${w.substring(1)})
      .join(' ');
  bool get isValidEmail =>
      RegExp(r'^[\\w.]+@[\\w]+\\.[\\w]+\$').hasMatch(this);
  String truncate(int max) => length > max ? '\${substring(0, max)}…' : this;
}

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  List<T> separated(T separator) {
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1) result.add(separator);
    }
    return result;
  }
}''',
  ),
];

// Categories for filtering
final _categories = [
  'All',
  ..._allSnippets.map((s) => s.category).toSet().toList()..sort(),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SnippetsScreen extends StatefulWidget {
  const SnippetsScreen({super.key});

  @override
  State<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFF10B981);

  String _query = '';
  String _category = 'All';
  Snippet? _selected;

  List<Snippet> get _filtered => _allSnippets.where((s) {
    final matchCat = _category == 'All' || s.category == _category;
    final q = _query.toLowerCase();
    final matchQ =
        q.isEmpty ||
        s.title.toLowerCase().contains(q) ||
        s.description.toLowerCase().contains(q) ||
        s.tags.any((t) => t.contains(q));
    return matchCat && matchQ;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                LucideIcons.code2,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Flutter Snippets Library',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_allSnippets.length} snippets',
                style: GoogleFonts.inter(fontSize: 11, color: _accent),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: isWide
          ? Row(
              children: [
                SizedBox(width: 340, child: _buildList(filtered)),
                Container(width: 1, color: _border),
                Expanded(child: _buildDetail()),
              ],
            )
          : _selected == null
          ? _buildList(filtered)
          : _buildDetail(),
    );
  }

  Widget _buildList(List<Snippet> filtered) {
    return Container(
      color: _surface,
      child: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search snippets…',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: Colors.white38,
                  size: 16,
                ),
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _accent),
                ),
              ),
            ),
          ),
          // Categories
          SizedBox(
            height: 36,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: _categories.map((cat) {
                final active = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? _accent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? _accent.withValues(alpha: 0.6)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: active ? _accent : Colors.white54,
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No snippets found',
                      style: GoogleFonts.inter(color: Colors.white24),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      final isActive = _selected?.id == s.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? _accent.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? _accent.withValues(alpha: 0.5)
                                  : Colors.white12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s.category,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: _accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white38,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail() {
    if (_selected == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.code2, size: 52, color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              'Select a snippet to view it',
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white24),
            ),
          ],
        ),
      );
    }
    final s = _selected!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          color: _surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width <= 900)
                IconButton(
                  icon: const Icon(
                    LucideIcons.arrowLeft,
                    color: Colors.white54,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _selected = null),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: s.tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$t',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: s.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied!', style: GoogleFonts.inter()),
                      backgroundColor: _accent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.copy, size: 14),
                label: Text('Copy', style: GoogleFonts.inter(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: _accent),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _border),
        // Code
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              s.code,
              style: GoogleFonts.robotoMono(
                fontSize: 13,
                color: const Color(0xFFCE9178),
                height: 1.65,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
