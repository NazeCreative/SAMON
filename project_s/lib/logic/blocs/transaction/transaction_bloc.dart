import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../presentation/bloc/wallet/wallet_bloc.dart';
import '../../../presentation/bloc/wallet/wallet_event.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository,
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByWallet>(_onLoadTransactionsByWallet);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      final transactions = await _transactionRepository.getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByWallet(
    LoadTransactionsByWallet event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      final transactions = await _transactionRepository.getTransactionsByWallet(event.walletId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      final transactions = await _transactionRepository.getTransactionsByDateRange(
        event.startDate,
        event.endDate,
      );
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      await _transactionRepository.addTransaction(event.transaction);
      emit(const TransactionOperationSuccess('Giao dịch đã được thêm thành công'));
      
      // Tải lại danh sách giao dịch sau khi thêm thành công
      add(const LoadTransactions());
      
      // Thông báo WalletBloc cập nhật (vì số dư ví đã thay đổi)
      // Lưu ý: Cần truyền context để có thể truy cập WalletBloc
      // Cách này sẽ được xử lý trong UI layer
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      await _transactionRepository.updateTransaction(event.transaction);
      emit(const TransactionOperationSuccess('Giao dịch đã được cập nhật thành công'));
      
      // Tải lại danh sách sau khi cập nhật thành công
      add(const LoadTransactions());
      
      // Thông báo WalletBloc cập nhật (vì số dư ví đã thay đổi)
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(const TransactionLoading());
      await _transactionRepository.deleteTransaction(event.transactionId);
      emit(const TransactionOperationSuccess('Giao dịch đã được xóa thành công'));
      
      // Tải lại danh sách sau khi xóa thành công
      add(const LoadTransactions());
      
      // Thông báo WalletBloc cập nhật (vì số dư ví đã thay đổi)
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
} 