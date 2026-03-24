import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Typography from '@mui/material/Typography';
import { NAV_TABS, type NavProps } from './navConfig';

const RAIL_WIDTH = 80;

export { RAIL_WIDTH };

export function RailNav({ activeTab, onChange }: NavProps) {
  return (
    <Box
      component="nav"
      sx={{
        position: 'fixed',
        left: 0,
        top: 0,
        bottom: 0,
        width: RAIL_WIDTH,
        backgroundColor: 'surface.container',
        borderRight: '1px solid rgba(202, 196, 208, 0.08)',
        zIndex: (theme) => theme.zIndex.drawer,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        pt: 2,
        gap: 0.5,
      }}
    >
      {NAV_TABS.map((tab) => {
        const isActive = activeTab === tab.value;
        return (
          <ButtonBase
            key={tab.value}
            onClick={(e) => onChange(e, tab.value)}
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              width: 64,
              py: 1,
              borderRadius: '16px',
              gap: 0.25,
              position: 'relative',
              color: isActive ? 'primary.main' : 'text.secondary',
              '&:hover': {
                backgroundColor: 'rgba(168, 199, 250, 0.08)',
              },
            }}
          >
            {/* Active indicator pill behind icon */}
            {isActive && (
              <Box
                sx={{
                  position: 'absolute',
                  top: 4,
                  width: 56,
                  height: 32,
                  backgroundColor: 'rgba(168, 199, 250, 0.16)',
                  borderRadius: '100px',
                }}
              />
            )}
            <Box sx={{ position: 'relative', zIndex: 1, display: 'flex' }}>
              {tab.icon}
            </Box>
            <Typography
              variant="caption"
              sx={{
                fontSize: '0.65rem',
                fontWeight: isActive ? 600 : 400,
                color: 'inherit',
                lineHeight: 1.2,
              }}
            >
              {tab.label}
            </Typography>
          </ButtonBase>
        );
      })}
    </Box>
  );
}
