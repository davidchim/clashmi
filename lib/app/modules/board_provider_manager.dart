import 'dart:convert';
import 'dart:io';

import 'package:clashmi/app/modules/board_session_persistent_manager.dart';
import 'package:clashmi/app/private/app_url_utils_private.dart';
import 'package:clashmi/app/runtime/return_result.dart';
import 'package:clashmi/app/utils/app_utils.dart';
import 'package:clashmi/app/utils/did.dart';
import 'package:clashmi/app/utils/http_utils.dart';
import 'package:clashmi/app/utils/path_utils.dart';
import 'package:clashmi/i18n/strings.g.dart';

enum BoardProviderType {
  v2board(name: "v2board"),
  xboard(name: "xboard"),
  sspanel(name: "sspanel");

  const BoardProviderType({required this.name});
  final String name;

  static bool support(String name) {
    return {v2board.name, xboard.name, sspanel.name}.contains(name);
  }
}

enum BoardProviderBenefit {
  panelLogin(name: "panel_login"),
  highlightPin(name: "highlight_pin"),
  logoBranding(name: "logo_branding"),
  renewalReminder(name: "renewal_reminder"),
  hideRecommendMenu(name: "hide_recommend_menu"),
  partialPanelRenewal(name: "partial_panel_renewal"),
  unbanSubscription(name: "unban_subscription"),
  customSpell(name: "custom_spell"),
  notificationPush(name: "notification_push");

  const BoardProviderBenefit({required this.name});
  final String name;

  static bool support(String name) {
    return {
      panelLogin.name,
      highlightPin.name,
      logoBranding.name,
      renewalReminder.name,
      hideRecommendMenu.name,
      partialPanelRenewal.name,
      unbanSubscription.name,
      customSpell.name,
      notificationPush.name,
    }.contains(name);
  }
}

class BoardProviderConfigError {
  int code;
  String? msg;
  BoardProviderConfigError({this.code = 0, this.msg});
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    code = map["code"] ?? 0;
    msg = map["msg"];
  }
}

class BoardProviderConfig {
  BoardProviderType type;
  String id;
  String name;
  List<String> names = [];
  String domain;
  List<String> domains = [];
  String userAgent;
  String urltestUrl;
  bool xhwid;
  bool web;
  bool overwrite = true;
  bool overwriteDns = true;
  String version;
  String userAgreement;
  String clientServiceUrl;
  String subscriptionChannelUrl;
  String loginUrl;
  String? registerUrl;
  String forgotPasswordUrl;
  String planUrl;
  String homeUrl;
  String appIconUrl;
  List<String> benefits = [];
  //benefits begin
  bool panelLogin = false;
  bool highlightPin = false;
  bool logoBranding = false;
  bool renewalReminder = false;
  bool hideRecommendMenu = false;
  bool hideNodeDetails = false;
  bool partialPanelRenewal = false;
  bool unbanSubscription = false;
  bool customSpell = false;
  bool notificationPush = false;
  //benefits end
  String botCookie;
  DateTime? lastUpdated;
  BoardProviderConfig({
    this.type = BoardProviderType.v2board,
    this.id = '',
    this.name = '',
    this.names = const [],
    this.domain = '',
    this.domains = const [],
    this.userAgent = '',
    this.urltestUrl = '',
    this.xhwid = false,
    this.web = false,
    this.overwrite = true,
    this.overwriteDns = true,
    this.version = '',
    this.userAgreement = '',
    this.clientServiceUrl = '',
    this.subscriptionChannelUrl = '',
    this.loginUrl = '',
    this.registerUrl,
    this.forgotPasswordUrl = '',
    this.planUrl = '',
    this.homeUrl = '',
    this.appIconUrl = '',
    this.benefits = const [],
    this.panelLogin = false,
    this.highlightPin = false,
    this.logoBranding = false,
    this.renewalReminder = false,
    this.hideRecommendMenu = false,
    this.hideNodeDetails = false,
    this.partialPanelRenewal = false,
    this.unbanSubscription = false,
    this.customSpell = false,
    this.notificationPush = false,
    this.botCookie = '', //'cf_clearance',
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'id': id,
    'name': name,
    'names': names,
    'domain': domain,
    'domains': domains,
    'user_agent': userAgent,
    'urltest_url': urltestUrl,
    'xhwid': xhwid,
    'web': web,
    'overwrite': overwrite,
    'overwrite_dns': overwriteDns,
    'version': version,
    'user_agreement': userAgreement,
    'client_service_url': clientServiceUrl,
    'subscription_channel_url': subscriptionChannelUrl,
    'login_url': loginUrl,
    'register_url': registerUrl,
    'forgot_password_url': forgotPasswordUrl,
    'plan_url': planUrl,
    'home_url': homeUrl,
    'app_icon_url': appIconUrl,
    'benefits': benefits,
    'panel_login': panelLogin,
    'highlight_pin': highlightPin,
    'logo_branding': logoBranding,
    'renewal_reminder': renewalReminder,
    'hide_recommend_menu': hideRecommendMenu,
    'hide_node_details': hideNodeDetails,
    'partial_panel_renewal': partialPanelRenewal,
    'unban_subscription': unbanSubscription,
    'custom_spell': customSpell,
    'notification_push': notificationPush,
    'bot_cookie': botCookie,
    //'last_updated': lastUpdated?.microsecondsSinceEpoch,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    final type_ = map["type"] ?? "";
    type = BoardProviderType.values.firstWhere(
      (e) => e.name == type_,
      orElse: () => BoardProviderType.v2board,
    );
    id = map["id"] ?? map["pid"] ?? "";
    name = map["name"] ?? "";
    names = List<String>.from(map["names"] ?? map["nicknames"] ?? []);
    if (name.isNotEmpty && !names.contains(name)) {
      names.add(name);
    }
    domain = map["domain"] ?? "";
    domains = List<String>.from(map["domains"] ?? []);
    userAgent = map["user_agent"] ?? "";
    urltestUrl = map["urltest_url"] ?? "";
    xhwid = map["xhwid"] ?? false;
    web = map["web"] ?? false;
    overwrite = map["overwrite"] ?? true;
    overwriteDns = map["overwrite_dns"] ?? true;
    version = map["version"] ?? "";
    userAgreement = map["user_agreement"] ?? "";
    clientServiceUrl = map["client_service_url"] ?? "";
    subscriptionChannelUrl = map["subscription_channel_url"] ?? "";
    loginUrl = map["login_url"] ?? "";
    registerUrl = map["register_url"];
    forgotPasswordUrl = map["forgot_password_url"] ?? "";
    planUrl = map["plan_url"] ?? "";
    homeUrl = map["home_url"] ?? "";
    appIconUrl = map["app_icon_url"] ?? "";
    benefits = List<String>.from(map["benefits"] ?? []);
    panelLogin = map["panel_login"] ?? false;
    highlightPin = map["highlight_pin"] ?? false;
    logoBranding = map["logo_branding"] ?? false;
    renewalReminder = map["renewal_reminder"] ?? false;
    hideRecommendMenu = map["hide_recommend_menu"] ?? false;
    hideNodeDetails = map["hide_node_details"] ?? false;
    partialPanelRenewal = map["partial_panel_renewal"] ?? false;
    unbanSubscription = map["unban_subscription"] ?? false;
    customSpell = map["custom_spell"] ?? false;
    notificationPush = map["notification_push"] ?? false;
    hideRecommendMenu = map["hide_recommend_menu"] ?? false;
    hideNodeDetails = map["hide_node_details"] ?? false;
    partialPanelRenewal = map["partial_panel_renewal"] ?? false;
    unbanSubscription = map["unban_subscription"] ?? false;
    customSpell = map["custom_spell"] ?? false;
    notificationPush = map["notification_push"] ?? false;
    botCookie = map["bot_cookie"] ?? ""; //"cf_clearance";
    // lastUpdated = map["last_updated"] != null
    //     ? DateTime.fromMicrosecondsSinceEpoch(map["last_updated"])
    //    : null;
  }
}

class BoardProviderManager {
  static List<BoardProviderConfig> _providers = [];
  static final Map<String, BoardProviderType> _providerTypeCache = {};
  static final Set<String> _notifyProviderIntegrationCache = {};
  static bool _saving = false;
  static Future<void> updateSessionProviders() async {
    await BoardSessionPersistentManager.instance().updateProviders(_providers);
  }

  static String get unknownProviderId => "000";
  static String get unknownProviderIdPrefix => "${unknownProviderId}_";
  static List<BoardProviderConfig> getProviders() {
    return _providers;
  }

  static Future<ReturnResult<BoardProviderType>> getProviderTypeById(
    Uri uri,
  ) async {
    if (uri.host.isEmpty) {
      return ReturnResult(
        error: ReturnResultError("getProviderTypeById: uri.host is empty"),
      );
    }

    final type = _providerTypeCache[uri.host];
    if (type != null) {
      return ReturnResult(data: type);
    }
    final urlSSpanel = "https://${uri.host}/auth/login";
    final urlV2OrXboard = "https://${uri.host}/#/login";

    var result = await HttpUtils.httpGetRequest(
      urlSSpanel,
      null,
      null,
      const Duration(seconds: 10),
      null,
      null,
      checkStatuscode: false,
    );
    if (result.error == null) {
      if (result.data!.item1 == 200 &&
          result.data!.item2.contains("SSPanel-UIM")) {
        _providerTypeCache[uri.host] = BoardProviderType.sspanel;
        return ReturnResult(data: BoardProviderType.sspanel);
      }
      String content = result.data!.item2.length > 512
          ? result.data!.item2.substring(0, 512)
          : result.data!.item2;
      return ReturnResult(
        error: ReturnResultError(
          "${t.loginScreen.unsupportedProvider}: ${Uri.decodeComponent(uri.toString())}\n$content",
        ),
      );
    }
    result = await HttpUtils.httpGetRequest(
      urlV2OrXboard,
      null,
      null,
      const Duration(seconds: 10),
      null,
      null,
      checkStatuscode: false,
    );
    if (result.error != null || result.data!.item1 != 200) {
      return ReturnResult(error: result.error);
    }
    if (result.data!.item2.contains("/Xboard/")) {
      _providerTypeCache[uri.host] = BoardProviderType.xboard;
      return ReturnResult(data: BoardProviderType.xboard);
    }
    if (result.data!.item2.contains("/auth/login")) {
      //sspanel
      String content = result.data!.item2.length > 512
          ? result.data!.item2.substring(0, 512)
          : result.data!.item2;
      return ReturnResult(
        error: ReturnResultError(
          "${t.loginScreen.unsupportedProvider}: ${Uri.decodeComponent(uri.toString())}\n$content",
        ),
      );
    }
    _providerTypeCache[uri.host] = BoardProviderType.v2board;
    return ReturnResult(data: BoardProviderType.v2board);
  }

  static BoardProviderConfig? getProviderById(String id) {
    if (id.isEmpty) {
      return null;
    }

    for (final provider in _providers) {
      if (provider.id == id) {
        return provider;
      }
    }
    return null;
  }

  static Future<ReturnResult<BoardProviderConfig>> getProviderByUri(
    Uri uri,
  ) async {
    final result = await BoardProviderManager.getProviderTypeById(uri);
    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    final providerType = result.data;
    final name = "${uri.scheme}://${Uri.decodeComponent(uri.host)}";
    for (final provider in _providers) {
      if (provider.type == providerType && provider.name == name) {
        return ReturnResult(data: provider);
      }
    }
    Set<String> ids = {};
    for (final provider in _providers) {
      ids.add(provider.id);
    }
    var id = "";
    for (int i = 0; ; i++) {
      id = "$unknownProviderIdPrefix$i";
      if (!ids.contains(id)) {
        break;
      }
    }
    final provider = BoardProviderConfig(
      type: providerType!,
      id: id,
      name: name,
      domain: uri.host,
      userAgent: "",
      urltestUrl: "",
      xhwid: false,
      web: false,
      overwrite: true,
      overwriteDns: true,
      version: "",
      userAgreement: "",
      clientServiceUrl: "",
      subscriptionChannelUrl: "",
      loginUrl: "",
      forgotPasswordUrl: "",
      planUrl: "",
      homeUrl: "",
      appIconUrl: "",
      benefits: [
        BoardProviderBenefit.panelLogin.name,
        BoardProviderBenefit.unbanSubscription.name,
      ],
    );

    _providers.add(provider);
    await _save();
    return ReturnResult(data: provider);
  }

  static Future<ReturnResult<BoardProviderConfig>> getProvider(
    String name,
  ) async {
    if (name.isEmpty) {
      return ReturnResult(
        error: ReturnResultError("getProvider: name is empty"),
      );
    }

    for (final provider in _providers) {
      if (provider.names.contains(name)) {
        if (provider.lastUpdated != null &&
            DateTime.now().difference(provider.lastUpdated!) <=
                const Duration(hours: 1)) {
          return ReturnResult(data: provider);
        }
        break;
      }
    }
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
    };
    final urlAndbody = BoardProviderPrivate.getBycodeUrlAndBody(
      app: AppUtils.getName(),
      version: AppUtils.getBuildinVersion(),
      did: await Did.getDid(),
      code: name,
    );
    var result = await HttpUtils.httpPostRequest(
      urlAndbody.item1,
      null,
      headers,
      urlAndbody.item3,
      const Duration(seconds: 10),
      null,
      null,
      null,
      checkStatuscode: false,
    );

    if (result.error != null && urlAndbody.item2.isNotEmpty) {
      result = await HttpUtils.httpPostRequest(
        urlAndbody.item2,
        null,
        headers,
        urlAndbody.item3,
        const Duration(seconds: 10),
        null,
        null,
        null,
        checkStatuscode: false,
      );
    }
    if (result.error != null) {
      for (final provider in _providers) {
        if (provider.names.contains(name)) {
          return ReturnResult(data: provider);
        }
      }
      return ReturnResult(error: ReturnResultError(result.error!.message));
    }

    if (result.data!.item1 != 200) {
      final updated = _providers
          .where((element) => element.names.contains(name))
          .isNotEmpty;
      _providers.removeWhere((element) => element.names.contains(name));
      if (updated) {
        await _save();
      }
      return ReturnResult(
        error: ReturnResultError(
          result.data!.item1 == 410
              ? "${t.loginScreen.unsupportedProvider}: $name"
              : "getProvider $name: http statuscode ${result.data!.item1} ${result.data!.item2}",
        ),
      );
    }

    final decodedBody = jsonDecode(result.data!.item2);
    BoardProviderConfig config = BoardProviderConfig();
    BoardProviderConfigError error = BoardProviderConfigError();
    error.fromJson(decodedBody);
    config.fromJson(decodedBody);
    if (error.code != 0) {
      final updated = _providers
          .where((element) => element.names.contains(name))
          .isNotEmpty;
      _providers.removeWhere((element) => element.names.contains(name));
      if (updated) {
        await _save();
      }
      return ReturnResult(
        error: ReturnResultError(
          error.msg ?? "getProvider $name: error code ${error.code}",
        ),
      );
    }
    if (config.id.isEmpty) {
      return ReturnResult(
        error: ReturnResultError(
          error.msg ?? "getProvider $name: invalid provider config, empty id",
        ),
      );
    }
    if (!config.names.contains(name)) {
      config.names.add(name);
    }

    var updated = _providers
        .where((element) => element.id == config.id)
        .isEmpty;

    config.lastUpdated = DateTime.now();
    if (updated) {
      _providers.add(config);
    } else {
      updated = true;
      for (var i = 0; i < _providers.length; i++) {
        if (_providers[i].id == config.id) {
          _providers[i] = config;
          break;
        }
      }
    }

    await _save();

    return ReturnResult(data: config);
  }

  static Future<void> notifyProviderIntegration(
    String id,
    String domain,
    String type,
  ) async {
    if (!id.startsWith(BoardProviderManager.unknownProviderIdPrefix)) {
      return;
    }
    final cacheKey = "$id|$domain|$type";
    if (_notifyProviderIntegrationCache.contains(cacheKey)) {
      return;
    }
    var headers = {
      HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
    };
    final urlAndbody = BoardProviderPrivate.getNotifyIntegrationUrlAndBody(
      app: AppUtils.getName(),
      version: AppUtils.getBuildinVersion(),
      did: await Did.getDid(),
      url: "https://$domain",
      type: type,
    );
    final result = await HttpUtils.httpPostRequest(
      urlAndbody.item1,
      null,
      headers,
      urlAndbody.item3,
      const Duration(seconds: 10),
      null,
      null,
      null,
      checkStatuscode: false,
    );
    if (result.error == null && result.data!.item1 == 200) {
      _notifyProviderIntegrationCache.add(cacheKey);
    }
  }

  static Future<void> init() async {
    await _load();
  }

  static Future<void> _save() async {
    if (_saving) {
      return;
    }
    _saving = true;
    final file = File(await PathUtils.providersConfigFilePath());
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String content = encoder.convert(_providers);
    await file.writeAsString(content);
    _saving = false;
  }

  static Future<void> _load() async {
    _providers = [];
    final file = File(await PathUtils.providersConfigFilePath());
    if (await file.exists()) {
      try {
        String content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        _providers = jsonData.map((item) {
          var config = BoardProviderConfig();
          config.fromJson(item);
          return config;
        }).toList();
      } catch (e) {}
    } else {
      await _save();
    }
    await updateSessionProviders();
    final sessionNames = BoardSessionPersistentManager.instance().getAllNames();
    for (var name in sessionNames) {
      getProvider(name);
    }
  }
}
