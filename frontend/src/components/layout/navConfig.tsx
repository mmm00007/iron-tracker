import HomeIcon from '@mui/icons-material/Home';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import HistoryIcon from '@mui/icons-material/History';
import BarChartIcon from '@mui/icons-material/BarChart';
import EventNoteIcon from '@mui/icons-material/EventNote';
import PersonOutlineIcon from '@mui/icons-material/PersonOutline';

export const NAV_TABS = [
  { label: 'Home', value: '/', icon: <HomeIcon /> },
  { label: 'Log', value: '/log', icon: <FitnessCenterIcon /> },
  { label: 'Plans', value: '/plans', icon: <EventNoteIcon /> },
  { label: 'History', value: '/history', icon: <HistoryIcon /> },
  { label: 'Stats', value: '/stats', icon: <BarChartIcon /> },
  { label: 'Profile', value: '/profile', icon: <PersonOutlineIcon /> },
] as const;

export type NavPath = (typeof NAV_TABS)[number]['value'];

export function getActiveTab(pathname: string): NavPath {
  // Exact match for home
  if (pathname === '/') return '/';
  // startsWith for all other tabs (skip Home to avoid matching everything)
  const match = NAV_TABS.slice(1).find((tab) => pathname.startsWith(tab.value));
  return match?.value ?? '/';
}

export interface NavProps {
  activeTab: NavPath;
  onChange: (event: React.SyntheticEvent, value: string) => void;
}
