// Mocks generated by Mockito 5.4.4 from annotations
// in robin_ai/test/data/repository/chat_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:robin_ai/core/service_names.dart' as _i5;
import 'package:robin_ai/data/datasources/chat_network.dart' as _i2;
import 'package:robin_ai/data/model/chat_message_network_model.dart' as _i4;
import 'package:robin_ai/domain/entities/chat_message_class.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [ChatNetworkDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockChatNetworkDataSource extends _i1.Mock
    implements _i2.ChatNetworkDataSource {
  MockChatNetworkDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<String> sendChatMessage(
    _i4.ChatMessageNetworkModel? message,
    _i5.ServiceName? serviceName,
    String? modelName,
    List<_i6.ChatMessage>? conversationHistory,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendChatMessage,
          [
            message,
            serviceName,
            modelName,
            conversationHistory,
          ],
        ),
        returnValue: _i3.Future<String>.value(_i7.dummyValue<String>(
          this,
          Invocation.method(
            #sendChatMessage,
            [
              message,
              serviceName,
              modelName,
              conversationHistory,
            ],
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<List<String>> getModels({required _i5.ServiceName? serviceName}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getModels,
          [],
          {#serviceName: serviceName},
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);
}
