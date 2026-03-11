import 'package:objectbox/objectbox.dart';

@Entity()
class ProcessingJobEntity {
  ProcessingJobEntity({
    this.id = 0,
    required this.jobKey,
    required this.stage,
    required this.message,
    required this.progress,
    this.selectedSource,
    this.failureReason,
    required this.updatedAtEpochMs,
  });

  @Id()
  int id;

  @Unique()
  String jobKey;

  String stage;
  String message;
  double progress;
  String? selectedSource;
  String? failureReason;
  int updatedAtEpochMs;
}
