import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/models/wallet_model.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc({required WalletRepository walletRepository})
      : _walletRepository = walletRepository,
        super(const WalletInitial()) {
    on<WalletsFetched>(_onWalletsFetched);
    on<ResetWallets>(_onResetWallets);
    on<WalletAdded>(_onWalletAdded);
    on<WalletUpdated>(_onWalletUpdated);
    on<WalletDeleted>(_onWalletDeleted);
  }

  Future<void> _onWalletsFetched(
    WalletsFetched event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoadInProgress());
    try {
      final wallets = await _walletRepository.getWallets();
      emit(WalletLoadSuccess(wallets));
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }

  Future<void> _onResetWallets(
    ResetWallets event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletInitial());
  }

  Future<void> _onWalletAdded(
    WalletAdded event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoadInProgress());
    try {
      await _walletRepository.addWallet(event.wallet);
      final wallets = await _walletRepository.getWallets();
      emit(WalletLoadSuccess(wallets));
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }

  Future<void> _onWalletUpdated(
    WalletUpdated event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoadInProgress());
    try {
      await _walletRepository.updateWallet(event.wallet);
      final wallets = await _walletRepository.getWallets();
      emit(WalletLoadSuccess(wallets));
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }

  Future<void> _onWalletDeleted(
    WalletDeleted event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoadInProgress());
    try {
      await _walletRepository.deleteWallet(event.walletId);
      final wallets = await _walletRepository.getWallets();
      emit(WalletLoadSuccess(wallets));
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }
} 