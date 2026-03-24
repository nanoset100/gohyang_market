import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// AI 서비스 - OpenAI Vision API로 사진 분석 + 상품 정보 자동 생성
/// 핵심 기능: 할머니가 사진 한 장 찍으면 AI가 모든 정보를 만들어줌
class AIService {
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// 상품 사진을 분석하여 상품 정보를 자동 생성
  /// 반환: {name, description, category, suggestedPrice, unit, story}
  static Future<Map<String, dynamic>> analyzeProductImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''당신은 한국 농수산물 전문가이자 식품 온톨로지 전문가입니다.
사진을 보고 아래 JSON 형식으로 상품 정보와 온톨로지 태그를 만들어주세요.

{
  "name": "상품명 (예: 신안 천일염, 자연산 전복)",
  "description": "구매자에게 매력적인 상품 설명 (3-4문장, 따뜻하고 진심어린 톤)",
  "category": "vegetable|fruit|seafood|grain|salt|processed|seaweed|other 중 하나",
  "suggestedPrice": 숫자만 (원 단위, 시세 반영),
  "unit": "단위 (예: 1kg, 1박스, 500g, 1봉)",
  "story": "이 상품의 매력 포인트 한 줄 (예: 갯벌 바람에 자연 건조한 천일염)",
  "season": ["제철 계절 (봄/여름/가을/겨울 중 해당되는 것)"],
  "bestMonths": [제철 월 숫자 배열 (예: [3,4,5])],
  "pairsWith": ["궁합이 좋은 식품 3-5개 (예: 천일염, 마늘, 고추)"],
  "recipes": ["이 재료로 만들 수 있는 요리 2-3개 (예: 양파볶음, 양파절임)"],
  "nutrition": ["주요 영양소 2-3개 (예: 퀘르세틴, 비타민C)"],
  "healthBenefits": ["건강 효과 2-3개 (예: 혈관건강, 면역력)"],
  "storage": "보관법 한 줄 (예: 서늘한 곳 상온보관 2-3주)",
  "keywords": ["검색용 키워드 3-5개 (예: 달콤, 아삭, 제철, 섬양파)"]
}

반드시 JSON만 응답하세요.'''
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '이 농수산물 사진을 분석해서 상품 정보를 만들어주세요.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;

        // JSON 파싱 (```json ... ``` 형식 처리)
        String jsonStr = content;
        if (jsonStr.contains('```')) {
          jsonStr = jsonStr
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }

        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } else {
        debugPrint('[AIService] API 오류: ${response.statusCode}');
        debugPrint('[AIService] ${response.body}');
        throw Exception('AI 분석에 실패했습니다');
      }
    } catch (e) {
      debugPrint('[AIService] 분석 실패: $e');
      rethrow;
    }
  }

  /// AI 추천 - 사용자 고향 기반 감성 추천 문구 생성
  static Future<String> generateRecommendation({
    required String userRegion,
    required String productName,
    required String productRegion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '한국 농수산물 추천 전문가입니다. 따뜻하고 감성적인 추천 문구를 한 줄로 작성하세요.',
            },
            {
              'role': 'user',
              'content':
                  '$userRegion 출신 사용자에게 $productRegion 의 $productName 을 추천하는 감성 문구를 만들어주세요.',
            },
          ],
          'max_tokens': 100,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] as String;
      }
      return '$productRegion에서 정성껏 키운 $productName, 고향의 맛을 느껴보세요';
    } catch (_) {
      return '$productRegion에서 정성껏 키운 $productName, 고향의 맛을 느껴보세요';
    }
  }
}
