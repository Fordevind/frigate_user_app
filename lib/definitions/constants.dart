/// Максимальная количество вводимых символов в поле ввода
const int maxLengthofInput = 512;
/// Длина пин-кода
const int maxPincodeLength = 5;
/// Количество попыток ввода пин-кода
const int countsOfPincodeInput = 5;

// HTTP related

const String urlEcho = 'https://json.flutter.su/echo';

const String myServer = 'http://192.168.1.2:23000';
const String dozorServer = 'http://85.140.40.196:23030';

const String myAuthURL = 'http://192.168.11.32:22000/auth';
const String myCommandURL = 'http://192.168.11.32:22000/command';

const String externalMyAuthURL = 'http://crm.votak.org:22000/auth';
const String externalMyCommandURL = 'http://crm.votak.org:22000/command';

const String externalAyurLoginURL = 'http://85.140.40.196:22000/login';
const String externalAyurCommandURL = 'http://85.140.40.196:22000/command';

const String contentTypeAppJSON = "application/json";

const String defaultLogin = 'Valeron';
const String defaultPassword = '1234';

const String messageArm = "cmd_arm";
const String messageDisarm = "cmd_disarm";

// Device related
const String statusDanger = "red";
const String statusArmed = "green";
const String statusDisarmed = "blue";

/// Время неактивности
const Duration inActivityDuration = Duration(seconds: 300);

/// Типы команд
enum CommandType {
  arm, disarm
}

const int defaultAttempts = 3;