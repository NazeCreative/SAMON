import 'package:equatable/equatable.dart';
import '../../../data/models/wallet_model.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletsFetched extends WalletEvent {
  const WalletsFetched();
}

class WalletAdded extends WalletEvent {
  final WalletModel wallet;

  const WalletAdded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletUpdated extends WalletEvent {
  final WalletModel wallet;

  const WalletUpdated(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletDeleted extends WalletEvent {
  final String walletId;

  const WalletDeleted(this.walletId);

  @override
  List<Object?> get props => [walletId];
} 