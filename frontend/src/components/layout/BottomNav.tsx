import Box from '@mui/material/Box';
import BottomNavigation from '@mui/material/BottomNavigation';
import BottomNavigationAction from '@mui/material/BottomNavigationAction';
import { NAV_TABS, type NavProps } from './navConfig';

export function BottomNav({ activeTab, onChange }: NavProps) {
  return (
    <Box
      component="nav"
      sx={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: (theme) => theme.zIndex.appBar,
      }}
    >
      <BottomNavigation value={activeTab} onChange={onChange} showLabels>
        {NAV_TABS.map((tab) => (
          <BottomNavigationAction
            key={tab.value}
            label={tab.label}
            value={tab.value}
            icon={tab.icon}
            sx={{
              '&.Mui-selected': {
                '& .MuiBottomNavigationAction-label': { color: 'primary.main' },
                '& .MuiSvgIcon-root': { color: 'primary.main' },
              },
              '&.Mui-selected::before': {
                content: '""',
                position: 'absolute',
                top: '8px',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '64px',
                height: '32px',
                backgroundColor: 'rgba(91, 234, 162, 0.12)',
                borderRadius: '100px',
                zIndex: -1,
              },
              position: 'relative',
              overflow: 'visible',
              minWidth: 0,
            }}
          />
        ))}
      </BottomNavigation>
    </Box>
  );
}
