import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the stock service
final stockServiceProvider = Provider<StockService>((ref) {
  return StockService();
});

/// Model class for stock data
class StockData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final int volume;
  
  StockData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.volume,
  });
  
  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      changePercent: (json['changePercent'] ?? 0.0).toDouble(),
      high: (json['high'] ?? 0.0).toDouble(),
      low: (json['low'] ?? 0.0).toDouble(),
      volume: json['volume'] ?? 0,
    );
  }
  
  @override
  String toString() {
    return 'Symbol: $symbol, Price: \$$price, Change: $change (${changePercent.toStringAsFixed(2)}%), '
           'Day Range: \$$low - \$$high, Volume: $volume';
  }
}

/// Model class for market news
class MarketNews {
  final String headline;
  final String summary;
  final String source;
  final DateTime datetime;
  final String? url;
  
  MarketNews({
    required this.headline,
    required this.summary,
    required this.source,
    required this.datetime,
    this.url,
  });
  
  factory MarketNews.fromJson(Map<String, dynamic> json) {
    return MarketNews(
      headline: json['headline'] ?? '',
      summary: json['summary'] ?? '',
      source: json['source'] ?? '',
      datetime: DateTime.fromMillisecondsSinceEpoch(json['datetime'] ?? 0),
      url: json['url'],
    );
  }
  
  @override
  String toString() {
    return '[$source] $headline - ${summary.substring(0, summary.length > 100 ? 100 : summary.length)}...';
  }
}

/// Service to fetch stock data and financial news
class StockService {
  final Dio _dio = Dio();
  
  // For demo purposes, we're using fake API keys
  // In a real app, these would be stored securely and not in code
  final String _fakeApiKey = 'demo_api_key';
  
  /// Get data for a specific stock symbol
  Future<StockData> getStockData(String symbol) async {
    try {
      // In a real implementation, this would call an actual API
      // For this demo, we'll just return mock data since we don't have a real API key
      
      // Example API call (commented out):
      // final response = await _dio.get(
      //   'https://financialdata.api/v1/quote',
      //   queryParameters: {
      //     'symbol': symbol,
      //     'apikey': _fakeApiKey,
      //   },
      // );
      
      // return StockData.fromJson(response.data);
      
      // Mock data based on symbol
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Generate somewhat realistic mock data
      final base = symbol.hashCode % 1000;
      final price = 100 + (base / 10);
      final change = (symbol.length % 2 == 0) ? 2.5 : -1.2;
      final changePercent = (change / price) * 100;
      
      return StockData(
        symbol: symbol.toUpperCase(),
        price: price,
        change: change,
        changePercent: changePercent,
        high: price + 3.5,
        low: price - 2.8,
        volume: 1000000 + (symbol.hashCode % 5000000),
      );
    } catch (e) {
      debugPrint('Error fetching stock data: $e');
      throw Exception('Failed to load stock data: $e');
    }
  }
  
  /// Get recent financial news
  Future<List<MarketNews>> getMarketNews({int limit = 5}) async {
    try {
      // In a real implementation, this would call an actual API
      // For this demo, we'll just return mock data since we don't have a real API key
      
      // Example API call (commented out):
      // final response = await _dio.get(
      //   'https://financialdata.api/v1/market-news',
      //   queryParameters: {
      //     'limit': limit,
      //     'apikey': _fakeApiKey,
      //   },
      // );
      
      // return (response.data as List)
      //     .map((item) => MarketNews.fromJson(item))
      //     .toList();
      
      // Mock data
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      return [
        MarketNews(
          headline: 'Federal Reserve Maintains Interest Rates',
          summary: 'The Federal Reserve announced today that it will keep interest rates unchanged following its latest policy meeting, citing moderate economic growth and controlled inflation.',
          source: 'Financial Times',
          datetime: DateTime.now().subtract(const Duration(hours: 3)),
          url: 'https://example.com/news/1',
        ),
        MarketNews(
          headline: 'Tech Stocks Rally as Earnings Beat Expectations',
          summary: 'Major technology companies reported better-than-expected quarterly earnings, driving a rally in tech stocks and pushing the Nasdaq to a new record high.',
          source: 'Wall Street Journal',
          datetime: DateTime.now().subtract(const Duration(hours: 5)),
          url: 'https://example.com/news/2',
        ),
        MarketNews(
          headline: 'Oil Prices Fall Amid Supply Concerns',
          summary: 'Crude oil prices dropped sharply today as major producers announced plans to increase output, raising concerns about oversupply in the global market.',
          source: 'Bloomberg',
          datetime: DateTime.now().subtract(const Duration(hours: 8)),
          url: 'https://example.com/news/3',
        ),
        MarketNews(
          headline: 'Cryptocurrency Market Shows Signs of Recovery',
          summary: 'After weeks of decline, the cryptocurrency market is showing signs of recovery, with Bitcoin and Ethereum both posting significant gains in the past 24 hours.',
          source: 'CoinDesk',
          datetime: DateTime.now().subtract(const Duration(hours: 12)),
          url: 'https://example.com/news/4',
        ),
        MarketNews(
          headline: 'European Markets Close Higher on Strong Economic Data',
          summary: 'European stock markets closed higher today following the release of strong economic indicators across the eurozone, boosting investor confidence in the region\'s recovery.',
          source: 'Reuters',
          datetime: DateTime.now().subtract(const Duration(hours: 14)),
          url: 'https://example.com/news/5',
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching market news: $e');
      throw Exception('Failed to load market news: $e');
    }
  }
  
  /// Format stock data and news into a string for the AI context
  Future<String> getFormattedMarketContext({
    List<String> symbols = const ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'],
    int newsLimit = 3,
  }) async {
    try {
      // Get stock data for all symbols
      final stockDataResults = await Future.wait(
        symbols.map((symbol) => getStockData(symbol)),
      );
      
      // Get market news
      final news = await getMarketNews(limit: newsLimit);
      
      // Format into a single string
      String context = 'CURRENT MARKET DATA:\n';
      
      // Add stock data
      context += '\nSTOCK PRICES:\n';
      for (final stock in stockDataResults) {
        context += '${stock.symbol}: \$${stock.price.toStringAsFixed(2)} '
                 '(${stock.change >= 0 ? '+' : ''}${stock.change.toStringAsFixed(2)}, '
                 '${stock.changePercent.toStringAsFixed(2)}%)\n';
      }
      
      // Add news
      context += '\nRECENT MARKET NEWS:\n';
      for (final item in news) {
        context += '- ${item.headline} [${item.source}]\n';
      }
      
      return context;
    } catch (e) {
      debugPrint('Error creating market context: $e');
      return 'Unable to retrieve current market data.';
    }
  }
} 