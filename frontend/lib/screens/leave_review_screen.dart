import 'package:flutter/material.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/services/review_service.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String? initialCityName;
  final CityReview? review;

  const LeaveReviewScreen({super.key, this.initialCityName, this.review});
  bool get isEdit => review != null;

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _impression = 1;
  int _people = 0;
  int _sights = 0;
  int _safety = 0;
  int _affordability = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      final r = widget.review!;
      _cityController.text = r.city ?? '';
      _commentController.text = r.comments;

      _impression = r.impression;
      _people = r.people;
      _sights = r.sights;
      _safety = r.safety;
      _affordability = r.affordability;
    } else if (widget.initialCityName != null) {
      _cityController.text = widget.initialCityName!;
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      if (widget.isEdit) {
        print('Updating review ${widget.review!.id}');
        await ReviewService.updateReview(
          reviewId: widget.review!.id,
          impression: _impression,
          people: _people,
          sights: _sights,
          safety: _safety,
          affordability: _affordability,
          comments: _commentController.text,
        );
      } else {
        await ReviewService.submitReview(
          cityName: _cityController.text,
          impression: _impression,
          people: _people,
          sights: _sights,
          safety: _safety,
          affordability: _affordability,
          comments: _commentController.text,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Review")),
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.isEdit ? "Edit Review" : "Leave Review",
                    style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 30),
                  
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: "Search for City",
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) => value!.isEmpty ? "Please enter a city" : null,
                  ),
                  const SizedBox(height: 32),

                  _buildRatingSection("Overall Impression", _impression, (val) => setState(() => _impression = val)),
                  _buildRatingSection("People & Vibe", _people, (val) => setState(() => _people = val)),
                  _buildRatingSection("Sights & Culture", _sights, (val) => setState(() => _sights = val)),
                  _buildRatingSection("Safety", _safety, (val) => setState(() => _safety = val)),
                  _buildRatingSection("Affordability", _affordability, (val) => setState(() => _affordability = val)),

                  const SizedBox(height: 24),
                  
                  // Comments
                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: "Comments (Optional)",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),

                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.isEdit ? "Edit review" : "Submit review", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(String title, int currentRating, Function(int) onRatingChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (index) {
                int starValue = index + 1;
                
                return GestureDetector(
                  onTap: () {
                    onRatingChanged(starValue);
                  },
                  child: Icon(
                    currentRating >= starValue ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
          ),
          Text(currentRating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}