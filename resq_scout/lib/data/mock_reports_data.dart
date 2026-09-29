import '../models/mission_report.dart';

const mockReports = <MissionReport>[
  MissionReport(
    id: 'rep-b27-01',
    missionTitle: 'Rescue B27',
    sector: 'Sector B, Uttarkashi',
    summary:
        'Initial landslide assessment filed. Two possible survivor '
        'locations flagged for the ground team.',
    status: ReportStatus.draft,
    filedBy: 'You',
    dateLabel: 'Today, 9:52 AM',
    severity: 'high',
    attachmentsCount: 2,
  ),
  MissionReport(
    id: 'rep-c12-01',
    missionTitle: 'Search C12',
    sector: 'Sector C, Uttarkashi',
    summary:
        'Search party reached the last known ridge signal. No visual '
        'contact yet; continuing sweep toward the tree line.',
    status: ReportStatus.submitted,
    filedBy: 'Team Alpha-02',
    dateLabel: 'Today, 8:15 AM',
    severity: 'medium',
    attachmentsCount: 1,
  ),
  MissionReport(
    id: 'rep-a03-01',
    missionTitle: 'Relief A03',
    sector: 'Sector A, Uttarkashi',
    summary:
        'Supply drop completed at the isolated village checkpoint. All '
        'packages accounted for, no incidents.',
    status: ReportStatus.reviewed,
    filedBy: 'Team Bravo-01',
    dateLabel: 'Yesterday, 4:40 PM',
    severity: 'low',
    attachmentsCount: 3,
  ),
  MissionReport(
    id: 'rep-a01-01',
    missionTitle: 'Relief A01',
    sector: 'Sector A, Uttarkashi',
    summary:
        'Medical supply drop closed out. Handover confirmed with local '
        'coordinator, no follow-up required.',
    status: ReportStatus.reviewed,
    filedBy: 'Team Bravo-01',
    dateLabel: '2 days ago',
    severity: 'low',
    attachmentsCount: 1,
  ),
  MissionReport(
    id: 'rep-c09-01',
    missionTitle: 'Search C09',
    sector: 'Sector C, Uttarkashi',
    summary:
        'Missing trekker located safe near the tree line and returned to '
        'base camp for a medical check.',
    status: ReportStatus.reviewed,
    filedBy: 'Team Alpha-02',
    dateLabel: '3 days ago',
    severity: 'medium',
    attachmentsCount: 2,
  ),
  MissionReport(
    id: 'rep-b21-01',
    missionTitle: 'Rescue B21',
    sector: 'Sector B, Uttarkashi',
    summary:
        'Flash flood evacuation closed out. 14 residents relocated, no '
        'casualties reported.',
    status: ReportStatus.submitted,
    filedBy: 'Team Alpha-02',
    dateLabel: '4 days ago',
    severity: 'high',
    attachmentsCount: 4,
  ),
];