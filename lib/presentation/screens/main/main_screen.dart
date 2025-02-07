import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vgv_challenge/presentation/presentation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showDownArrow = false;
  bool _showFavoritesButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      final size = MediaQuery.of(context).size;
      _showDownArrow = _scrollController.offset < 30;
      _showFavoritesButton = _scrollController.offset > size.height * .2;
    });
  }

  @override
  Widget build(BuildContext context) {
    const favoriteCTAButton = FavoritesScreenCallToActionWidget();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Material(
              color: Colors.brown[500],
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  CustomAppBarWidget(scrollController: _scrollController),
                  const _SectionTitle(),
                  CoffeeCardListWidget(
                    onReturning: () {
                      final bloc = context.read<CoffeeCardListBloc>();
                      debugPrint(bloc.toString());
                      bloc.add(
                        LoadCoffeeCardList(),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showDownArrow ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 64,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _showFavoritesButton ? favoriteCTAButton : null,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        // ignore: lines_longer_than_80_chars
        child: BlocBuilder<CoffeeCardListBloc, CoffeeCardListState>(
          builder: (context, state) {
            // ignore: lines_longer_than_80_chars
            if (state is CoffeeCardListLoaded && _couldNotRender(state)) {
              return const Offstage();
            }
            return Text(
              context.l10n.lastSeenText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    );
  }

  bool _couldNotRender(CoffeeCardListLoaded state) {
    final list = state.list;
    final noFileExists = !list.any((coffee) => coffee.asFile.existsSync());
    return list.isEmpty || noFileExists;
  }
}
