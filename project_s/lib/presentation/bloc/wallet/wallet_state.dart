import '../../../data/models/wallet_model.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoadInProgress extends WalletState {
  const WalletLoadInProgress();
}

class WalletLoadSuccess extends WalletState {
  final List<WalletModel> wallets;
  const WalletLoadSuccess(this.wallets);
}

class WalletLoadFailure extends WalletState {
  final String error;
  const WalletLoadFailure(this.error);
} 