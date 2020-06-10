import 'dart:math';

import 'package:fusecash/models/jobs/base.dart';
import 'package:fusecash/models/pro/pro_wallet_state.dart';
import 'package:fusecash/models/pro/token.dart';
import 'package:fusecash/redux/actions/pro_mode_wallet_actions.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:redux/redux.dart';

final proWalletReducers = combineReducers<ProWalletState>([
  TypedReducer<ProWalletState, StartListenToTransferEventsSuccess>(_startListenToTransferEventsSuccess),
  TypedReducer<ProWalletState, UpdateToken>(_updateToken),
  TypedReducer<ProWalletState, UpadteBlockNumber>(_updateBlockNumber),
  TypedReducer<ProWalletState, StartProcessingTokensJobs>(_startProcessingTokensJobs),
  TypedReducer<ProWalletState, StartFetchTransferEvents>(_startFetchTransferEvents),
  TypedReducer<ProWalletState, InitWeb3ProModeSuccess>(_initWeb3ProModeSuccess),
  TypedReducer<ProWalletState, CreateLocalAccountSuccess>(_createNewWalletSuccess),
  TypedReducer<ProWalletState, GetTokenListSuccess>(_getTokenListSuccess),
  TypedReducer<ProWalletState, AddProJob>(_addProJob),
  TypedReducer<ProWalletState, StartFetchTokensBalances>(_startFetchTokensBalances),
  TypedReducer<ProWalletState, UpdateEtherBalabnce>(_updateEtherBalabnce),
  TypedReducer<ProWalletState, UpdateSwapActions>(_updateSwapActions),
  TypedReducer<ProWalletState, StartProcessingSwapActions>(_startProcessingSwapActions),
]);

ProWalletState _updateSwapActions(ProWalletState state, UpdateSwapActions action) {
  return state.copyWith(swapActions: action.swapActions);
}

ProWalletState _updateEtherBalabnce(ProWalletState state, UpdateEtherBalabnce action) {
  return state.copyWith(etherBalance: action.balance);
}

ProWalletState _addProJob(ProWalletState state, AddProJob action) {
  Token currentToken = state.erc20Tokens[action.tokenAddress];
  Token newToken = currentToken.copyWith(jobs: List<Job>.from(currentToken?.jobs ?? [])..add(action.job));
  Map<String, Token> newOne = Map<String, Token>.from(state.erc20Tokens);
  newOne[action.tokenAddress] = newToken;
  return state.copyWith(erc20Tokens: newOne);
}

ProWalletState _createNewWalletSuccess(ProWalletState state, CreateLocalAccountSuccess action) {
  return ProWalletState.initial();
}

ProWalletState _startProcessingTokensJobs(ProWalletState state, StartProcessingTokensJobs action) {
  return state.copyWith(isProcessingTokensJobs: true);
}

ProWalletState _startProcessingSwapActions(ProWalletState state, StartProcessingSwapActions action) {
  return state.copyWith(isProcessingSwapActions: true);
}

ProWalletState _startFetchTransferEvents(ProWalletState state, StartFetchTransferEvents action) {
  return state.copyWith(isFetchTransferEvents: true);
}

ProWalletState _initWeb3ProModeSuccess(ProWalletState state, InitWeb3ProModeSuccess action) {
  return state.copyWith(web3: action.web3);
}

ProWalletState _updateBlockNumber(ProWalletState state, UpadteBlockNumber action) {
  return state.copyWith(blockNumber: action.blockNumber);
}

ProWalletState _startListenToTransferEventsSuccess(ProWalletState state, StartListenToTransferEventsSuccess action) {
  return state.copyWith(isListenToTransferEvents: true);
}

ProWalletState _getTokenListSuccess(ProWalletState state, GetTokenListSuccess action) {
  List<Token> currentErc20TokensList = List<Token>.from(action.erc20Tokens.values ?? Iterable<Token>.empty());
  Map<String, Token> newOne = Map<String, Token>.from(state.erc20Tokens..removeWhere((key, token) {
    if (token.timestamp == 0) return false;
    double formatedValue = token.amount / BigInt.from(pow(10, token.decimals));
    return formatedValue.compareTo(0) != 1;
  }));
  for (Token token in currentErc20TokensList) {
    if (newOne.containsKey(token.address)) {
      newOne[token.address] = newOne[token.address].copyWith(amount: token.amount, timestamp: token.timestamp, priceInfo: token.priceInfo);
    } else if (!newOne.containsKey(token.address)) {
      newOne[token.address] = token;
    }
  }
  return state.copyWith(erc20Tokens: newOne);
}

ProWalletState _updateToken(ProWalletState state, UpdateToken action) {
  Map<String, Token> newOne = Map<String, Token>.from(state.erc20Tokens);
  newOne[action.tokenToUpdate.address] = action.tokenToUpdate;
  return state.copyWith(erc20Tokens: newOne);
}

ProWalletState _startFetchTokensBalances(ProWalletState state, StartFetchTokensBalances action) {
  return state.copyWith(isFetchTokensBalances: true);
}