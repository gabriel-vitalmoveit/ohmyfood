import 'package:flutter/material.dart';
import 'toast_helper.dart';

class ErrorHandler {
  static void handleError(BuildContext? context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? _extractErrorMessage(error);
    
    if (context != null) {
      ToastHelper.showError(context, message);
    }
  }

  static String _extractErrorMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';
    
    final errorString = error.toString();
    
    // Erros de conexão
    if (errorString.contains('SocketException') || 
        errorString.contains('Failed host lookup') ||
        errorString.contains('Connection refused')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    
    // Timeout
    if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
      return 'Tempo de espera esgotado. Tente novamente.';
    }
    
    // Erros HTTP
    if (errorString.contains('404')) {
      return 'Recurso não encontrado.';
    }
    if (errorString.contains('401') || errorString.contains('403')) {
      return 'Não autorizado. Faça login novamente.';
    }
    if (errorString.contains('500')) {
      return 'Erro no servidor. Tente mais tarde.';
    }
    
    // Erros de autenticação
    if (errorString.contains('AuthException') || errorString.contains('Unauthorized')) {
      return 'Credenciais inválidas.';
    }
    
    // Outros erros
    return errorString.length > 100 
        ? '${errorString.substring(0, 100)}...' 
        : errorString;
  }

  static void handleSuccess(BuildContext? context, String message) {
    if (context != null) {
      ToastHelper.showSuccess(context, message);
    }
  }
}

