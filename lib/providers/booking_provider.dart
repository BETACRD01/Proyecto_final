import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../core/services/firebase_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadUserBookings(String userId, {bool isProvider = false}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      String field = isProvider ? 'providerId' : 'clientId';
      QuerySnapshot snapshot = await FirebaseService.bookingsCollection
          .where(field, isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar reservas');
      _setLoading(false);
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.bookingsCollection
          .doc(bookingId)
          .get();

      if (doc.exists) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      _setError('Error al obtener reserva');
      return null;
    }
  }

  Future<bool> createBooking(BookingModel booking) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.bookingsCollection
          .doc(booking.id)
          .set(booking.toMap());

      _bookings.insert(0, booking);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear reserva');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    _setLoading(true);
    _setError(null);
    
    try {
      Map<String, dynamic> updateData = {
        'status': status.index,
        'updatedAt': Timestamp.now(),
      };

      if (status == BookingStatus.completed) {
        updateData['completedAt'] = Timestamp.now();
      }

      await FirebaseService.bookingsCollection
          .doc(bookingId)
          .update(updateData);

      int index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          completedAt: status == BookingStatus.completed ? DateTime.now() : null,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al actualizar estado de reserva');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.bookingsCollection
          .doc(bookingId)
          .update({
        'status': BookingStatus.cancelled.index,
        'cancellationReason': reason,
        'updatedAt': Timestamp.now(),
      });

      int index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: reason,
          updatedAt: DateTime.now(),
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al cancelar reserva');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rateBooking(String bookingId, double rating, String? review) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await FirebaseService.bookingsCollection
          .doc(bookingId)
          .update({
        'rating': rating,
        'review': review,
        'updatedAt': Timestamp.now(),
      });

      int index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          rating: rating,
          review: review,
          updatedAt: DateTime.now(),
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al calificar servicio');
      _setLoading(false);
      return false;
    }
  }

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  List<BookingModel> getUpcomingBookings() {
    DateTime now = DateTime.now();
    return _bookings.where((booking) {
      return booking.status == BookingStatus.confirmed &&
          booking.scheduledDate.isAfter(now);
    }).toList();
  }

  List<BookingModel> getCompletedBookings() {
    return _bookings.where((booking) => 
        booking.status == BookingStatus.completed).toList();
  }

  void clearError() {
    _setError(null);
  }
}
