import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'groups.dart';
import 'report.dart';
import 'schedule.dart';
import 'stats.dart';
import 'student.dart';
import 'weeks.dart';

part 'api.g.dart';

class ConsolidatedInterceptor extends Interceptor {
  static const database = 'cons';

  final String login;
  final String password;

  ConsolidatedInterceptor({required this.login, required this.password});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'base': database,
      'login': login,
      'pass': password,
      'format': 'json',
    });
    super.onRequest(options, handler);
  }
}

@RestApi(baseUrl: 'https://wq.lms-school.ru')
abstract class ConsolidatedClient {
  factory ConsolidatedClient(Dio dio) = _ConsolidatedClient;

  @GET('/?action=consolidated.statistic')
  Future<StatsResponse> getStats();

  @GET('/?action=consolidated.statistic')
  Future<StatsResponse> getStatsForSchool(
    @Query('idOrg') String school,
  );

  @GET('/?action=consolidated.statistic_course')
  Future<StatsResponse> getStatsByTeachers(
    @Query('idOrg') String school,
    @Query('idCourse') String course,
  );

  @GET('/?action=consolidated.list_classes')
  Future<GroupsResponse> getGroups(
    @Query('idOrg') String school,
  );

  @GET('/?action=consolidated.list_students')
  Future<StudentsListResponse> getStudents(
    @Query('idOrg') String org,
    @Query('group') String groupID,
  );

  @GET('/?action=consolidated.student_info')
  Future<StudentDetailsResponse> getStudentDetails(
    @Query('idOrg') String school,
    @Query('student') String student,
  );

  @GET('/?action=consolidated.report.GeneralStatisticsOne')
  Future<ReportResponse> getReport(
    @Query('id') String id,
    @Query('date') String date,
  );
}

@RestApi(baseUrl: 'https://wq.lms-school.ru')
abstract class BaseClient {
  factory BaseClient(Dio dio) = _BaseClient;

  @GET('/?action=currentyearweeks&format=json')
  Future<WeeksResponse> getWeeks(
    @Query('base') String dbName,
  );

  @GET('/?action=fullschedule&format=json')
  Future<ScheduleResponse> getFullSchedule(
    @Query('variant') String variant,
    @Query('base') String dbName,
  );
}

final _dio = Dio()
  ..interceptors
      .add(ConsolidatedInterceptor(login: 'nnz', password: 'Sonyk12345678'));

final _baseDio = Dio();

final baseClient = BaseClient(_baseDio);
final client = ConsolidatedClient(_dio);
