import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/wallet/wallet_bloc.dart';
import '../presentation/bloc/wallet/wallet_event.dart';
import '../presentation/bloc/wallet/wallet_state.dart';
import '../logic/blocs/category/category_bloc.dart';
import '../logic/blocs/category/category_event.dart';
import '../data/models/wallet_model.dart';
import 'edit_wallet_screen.dart';
import 'add_wallet_screen.dart';
import '../core/utils/formatter.dart';
import 'dart:io';

String formatVNCurrency(num amount) {
  // Nếu đã có Formatter.formatCurrency thì dùng luôn
  try {
    return Formatter.formatCurrency(amount.toDouble());
  } catch (e) {
    // Nếu không có Formatter, dùng cách thủ công
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showBalances = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const WalletsFetched());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  void _toggleVisibility() {
    setState(() {
      _showBalances = !_showBalances;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Ví',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 20)),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoadInProgress) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (state is WalletLoadSuccess) {
                  final wallets = state.wallets;
                  final totalBalance = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showBalances ? formatVNCurrency(totalBalance) : '****** ₫',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(_showBalances ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                        onPressed: _toggleVisibility,
                      ),
                    ],
                  );
                } else if (state is WalletLoadFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ví của tôi',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddWalletScreen(),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              backgroundColor: Color(0xffffbf0f),
                              child: Icon(Icons.add_circle_outline_outlined, color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<WalletBloc, WalletState>(
                        builder: (context, state) {
                          if (state is WalletLoadInProgress) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is WalletLoadSuccess) {
                            final wallets = state.wallets;
                            if (wallets.isEmpty) {
                              return const Center(child: Text('Chưa có ví nào', style: TextStyle(color: Colors.white70)));
                            }
                            return ListView.builder(
                              itemCount: wallets.length,
                              itemBuilder: (context, index) {
                                final wallet = wallets[index];
                                return WalletItem(
                                  wallet: wallet,
                                  showBalance: _showBalances,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditWalletScreen(wallet: wallet),
                                      ),
                                    );
                                    
                                    if (result != null && context.mounted) {
                                      if (result is WalletModel) {
                                        // Cập nhật ví
                                        context.read<WalletBloc>().add(WalletUpdated(result));
                                      } else if (result is Map<String, dynamic> && result['action'] == 'delete') {
                                        // Xóa ví
                                        context.read<WalletBloc>().add(WalletDeleted(result['walletId']));
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          } else if (state is WalletLoadFailure) {
                            return Center(child: Text('Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  final WalletModel wallet;
  final bool showBalance;
  final VoidCallback onTap;

  const WalletItem({
    super.key,
    required this.wallet,
    required this.showBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: buildIcon(wallet.icon),
        ),
      ),
      title: Text(wallet.name, style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              showBalance ? formatVNCurrency(wallet.balance) : '****** ₫',
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
    );
  }

  Widget buildIcon(String iconPath) {
    // Handle null or empty iconPath
    if (iconPath.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.wallet,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    Widget imageWidget;
    if (iconPath.startsWith('http')) {
      // Network image (Cloudinary URL)
      imageWidget = Image.network(
        iconPath,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.wallet,
              color: Colors.white,
              size: 20,
            ),
          );
        },
      );
    } else if (iconPath.startsWith('/') || iconPath.contains('storage')) {
      // Local file path
      try {
        imageWidget = Image.file(
          File(iconPath),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wallet,
                color: Colors.white,
                size: 20,
              ),
            );
          },
        );
      } catch (e) {
        // Fallback if file doesn't exist
        imageWidget = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.wallet,
            color: Colors.white,
            size: 20,
          ),
        );
      }
    } else {
      // Asset image
      imageWidget = Image.asset(
        iconPath,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.wallet,
              color: Colors.white,
              size: 20,
            ),
          );
        },
      );
    }

    return Container(
      width: 40,
      height: 40,
      child: imageWidget,
    );
  }
}
