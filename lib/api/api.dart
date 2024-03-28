import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'groups.dart';
import 'report.dart';
import 'schedule.dart';
import 'stats.dart';
import 'student.dart';
import 'weeks.dart';
import 'phonebook.dart';
import 'count.dart';

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

  @GET('/?action=consolidated.phonebook&school=0')
  Future<PhonebookResponse> getPhonebookReport(
    @Query('idOrg') String schoolId,
  );

  @GET('/?action=consolidated.report.students_total&school=0')
  Future<CountReportResponse> getCountReport(
    @Query('idOrg') String schoolId,
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

class LmsErrorInterceptor extends Interceptor {
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.data is Map) {
      final answer = response.data['Answer'];

      if (answer['Result'] == 'Error') {
        throw answer['Message'];
      }
    }
    handler.next(response);
  }
}

final consolidatedDio = Dio()..interceptors.add(LmsErrorInterceptor());
final baseDio = Dio()..interceptors.add(LmsErrorInterceptor());

final baseClient = BaseClient(baseDio);
final client = ConsolidatedClient(consolidatedDio);
