import '../models/user_profile.dart';

const mockUserProfile = UserProfile(
  id: 'user-v01',
  name: 'Rescuer V',
  initials: 'V',
  role: 'Field Rescuer',
  team: 'Team Alpha-02',
  sector: 'Uttarkashi, Uttarakhand',
  phone: '+91 98765 43210',
  email: 'rescuer.v@resqvision.org',
  activeSince: 'Since Mar 2024',
  missionsCompleted: 27,
  hoursInField: 412,
  certifications: [
    'Wilderness First Responder',
    'Swift Water Rescue',
    'Drone Operator (Level 2)',
  ],
);