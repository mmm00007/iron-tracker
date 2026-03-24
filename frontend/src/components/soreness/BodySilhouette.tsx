import Box from '@mui/material/Box';

/**
 * Color a muscle region based on its soreness rating.
 * 0 = green (no soreness), 1-2 = yellow/amber, 3-4 = red, unrated = gray.
 */
function getMuscleColor(level: number | undefined): { fill: string; stroke: string } {
  if (level === undefined) return { fill: 'rgba(120, 120, 120, 0.15)', stroke: 'rgba(120, 120, 120, 0.3)' };
  if (level === 0) return { fill: 'rgba(102, 187, 106, 0.3)', stroke: '#66BB6A' };
  if (level <= 2) return { fill: 'rgba(255, 193, 7, 0.3)', stroke: '#FFC107' };
  return { fill: 'rgba(244, 67, 54, 0.35)', stroke: '#F44336' };
}

interface MuscleRegion {
  name: string;
  path: string;
}

// Simplified front-view muscle regions as SVG paths within a 200x440 viewBox.
// Each path approximates a major muscle group's location on a human silhouette.
const MUSCLE_REGIONS: MuscleRegion[] = [
  // Head/neck (not a rated muscle, just body outline context)
  {
    name: '__head',
    path: 'M88,10 Q100,0 112,10 Q120,20 118,38 Q116,48 112,50 L88,50 Q84,48 82,38 Q80,20 88,10 Z',
  },
  // Neck
  {
    name: '__neck',
    path: 'M92,50 L108,50 L110,62 L90,62 Z',
  },
  // Shoulders (Deltoids)
  {
    name: 'Shoulders',
    path: 'M60,70 Q56,64 50,68 Q42,74 40,90 L52,100 L60,88 Z M140,70 Q144,64 150,68 Q158,74 160,90 L148,100 L140,88 Z',
  },
  // Chest (Pectorals)
  {
    name: 'Chest',
    path: 'M66,78 Q100,72 134,78 L136,110 Q100,118 64,110 Z',
  },
  // Biceps
  {
    name: 'Biceps',
    path: 'M40,96 L52,102 L54,150 L46,168 L36,160 L34,120 Z M160,96 L148,102 L146,150 L154,168 L164,160 L166,120 Z',
  },
  // Forearms
  {
    name: 'Forearms',
    path: 'M34,162 L46,170 L42,220 L32,230 L26,218 Z M166,162 L154,170 L158,220 L168,230 L174,218 Z',
  },
  // Abdominals
  {
    name: 'Abdominals',
    path: 'M78,112 L122,112 L124,180 Q100,186 76,180 Z',
  },
  // Obliques
  {
    name: 'Obliques',
    path: 'M64,112 L78,112 L76,178 L62,168 Z M136,112 L122,112 L124,178 L138,168 Z',
  },
  // Hip Flexors
  {
    name: 'Hip Flexors',
    path: 'M76,180 L96,186 L88,204 L72,196 Z M124,180 L104,186 L112,204 L128,196 Z',
  },
  // Quadriceps
  {
    name: 'Quadriceps',
    path: 'M72,198 L92,206 L88,300 L70,300 L66,260 Z M128,198 L108,206 L112,300 L130,300 L134,260 Z',
  },
  // Adductors
  {
    name: 'Adductors',
    path: 'M92,206 L100,210 L98,270 L88,270 Z M108,206 L100,210 L102,270 L112,270 Z',
  },
  // Calves
  {
    name: 'Calves',
    path: 'M68,306 L88,306 L86,376 L74,380 L66,360 Z M132,306 L112,306 L114,376 L126,380 L134,360 Z',
  },
  // Feet (not rated)
  {
    name: '__feet',
    path: 'M66,378 L86,378 L88,400 Q78,408 64,400 Z M134,378 L114,378 L112,400 Q122,408 136,400 Z',
  },
  // Traps
  {
    name: 'Traps',
    path: 'M84,56 L90,62 L110,62 L116,56 L134,70 Q100,66 66,70 Z',
  },
];

interface BodySilhouetteProps {
  /** Map of muscle group name to soreness level (0-4). Unrated muscles show as gray. */
  ratings: Map<string, number>;
}

/**
 * Visual-only front-view body silhouette that colors muscle regions
 * based on their soreness rating.
 *
 * - Green (0): no soreness
 * - Yellow (1-2): mild to moderate
 * - Red (3-4): severe to extreme
 * - Gray: unrated
 */
export function BodySilhouette({ ratings }: BodySilhouetteProps) {
  return (
    <Box sx={{ width: '100%', maxWidth: 180, mx: 'auto' }}>
      <svg
        viewBox="0 0 200 420"
        width="100%"
        style={{ display: 'block' }}
        aria-label="Body silhouette showing muscle soreness levels"
        role="img"
      >
        {/* Background body outline */}
        <path
          d="M100,8 Q115,4 118,18 Q122,36 118,48 L112,50 L116,56
             L140,70 Q158,76 162,92 L166,160 L174,218 L168,232
             L158,222 L148,102 L140,88 L136,110 L138,170 L134,260
             L136,300 L136,360 L138,380 L136,402 Q122,410 112,400
             L112,306 L112,270 L108,206 L100,210 L92,206 L88,270
             L88,306 L88,400 Q78,410 64,402 L62,380 L64,360 L66,300
             L66,260 L62,170 L64,110 L60,88 L52,102 L42,222 L32,232
             L26,218 L34,160 L38,92 Q42,76 60,70 L84,56 L88,50
             L82,48 Q78,36 82,18 Q85,4 100,8 Z"
          fill="rgba(42, 42, 62, 0.6)"
          stroke="rgba(100, 100, 120, 0.4)"
          strokeWidth="0.8"
        />

        {/* Muscle regions colored by rating */}
        {MUSCLE_REGIONS.map((region) => {
          // Skip non-muscle decorative parts
          if (region.name.startsWith('__')) return null;

          const level = ratings.get(region.name);
          const { fill, stroke } = getMuscleColor(level);

          return (
            <path
              key={region.name}
              d={region.path}
              fill={fill}
              stroke={stroke}
              strokeWidth="0.8"
              opacity={0.9}
            />
          );
        })}
      </svg>
    </Box>
  );
}
