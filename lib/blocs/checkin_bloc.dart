import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magentahrd/blocs/checkin_bloc.dart';
import 'package:magentahrd/blocs/checkin_event.dart';
import 'package:magentahrd/blocs/checkin_submission.dart';
import 'package:magentahrd/blocs/checkin_state.dart';
import 'package:magentahrd/repositories/checkin.dart';

class CheckinBloc extends Bloc<CheckinEvent, CheckinState> {
  final CheckinRepository? checkinRepository;

  CheckinBloc({this.checkinRepository}) : super(CheckinState());

  @override
  Stream<CheckinState> mapEventToState(CheckinEvent event) async* {
    // TODO: implement mapEventToState
    //username updated
    if (event is CheckinImage) {
      yield state.copyWith(image: event.image);

      //password updated
    } else if (event is CheckinLatitude) {
      yield state.copyWith(latitude: event.latitude);

      //form submitted
    } else if (event is CheckinLongitude) {
      yield state.copyWith(longitude: event.longitude);
    } else if (event is CheckinDateTime) {
      yield state.copyWith(dateTime: event.dateTime);
    } else if (event is CheckinEmployeeId) {
      yield state.copyWith(employeeId: event.employeeId);
    } else if (event is CheckinAddress) {
      yield state.copyWith(address: event.address);
    } else if (event is CheckinSubmitted) {
      yield state.copyWith(formStatus: CheckinSubmitting());

      try {
        await checkinRepository!.checkin(
            employeeId: state.employeeId,
            image: state.image,
            latitude: state.latitude,
            longitude: state.longitude,
            address: state.address,
            dateTime: state.dateTime);
        yield state.copyWith(formStatus: CheckinSubmissionSuccess());
      } catch (e) {
        yield state.copyWith(formStatus: CheckinSubmissionFaied(e.toString()));
      }
    }
  }
}
