import Box from '@mui/material/Box';

const SORENESS_COLORS = ['#66BB6A', '#8BC34A', '#FFC107', '#FF9800', '#F44336'];

interface MuscleRegion {
  id: number;
  name: string;
  cx: number;
  cy: number;
  rx: number;
  ry: number;
}

// Simplified front body muscle regions (relative to 200x400 viewbox)
const FRONT_MUSCLES: MuscleRegion[] = [
  { id: 1, name: 'Chest', cx: 100, cy: 105, rx: 35, ry: 18 },
  { id: 2, name: 'Shoulders', cx: 58, cy: 80, rx: 14, ry: 12 },
  { id: 3, name: 'Shoulders R', cx: 142, cy: 80, rx: 14, ry: 12 },
  { id: 4, name: 'Biceps', cx: 52, cy: 140, rx: 10, ry: 22 },
  { id: 5, name: 'Biceps R', cx: 148, cy: 140, rx: 10, ry: 22 },
  { id: 6, name: 'Abdominals', cx: 100, cy: 155, rx: 22, ry: 30 },
  { id: 7, name: 'Quadriceps', cx: 82, cy: 250, rx: 16, ry: 40 },
  { id: 8, name: 'Quadriceps R', cx: 118, cy: 250, rx: 16, ry: 40 },
  { id: 9, name: 'Calves', cx: 82, cy: 335, rx: 10, ry: 25 },
  { id: 10, name: 'Calves R', cx: 118, cy: 335, rx: 10, ry: 25 },
  { id: 11, name: 'Forearms', cx: 44, cy: 180, rx: 8, ry: 20 },
  { id: 12, name: 'Forearms R', cx: 156, cy: 180, rx: 8, ry: 20 },
];

// Back body muscle regions
const BACK_MUSCLES: MuscleRegion[] = [
  { id: 13, name: 'Traps', cx: 100, cy: 72, rx: 25, ry: 12 },
  { id: 14, name: 'Back', cx: 100, cy: 115, rx: 30, ry: 25 },
  { id: 15, name: 'Triceps', cx: 52, cy: 140, rx: 10, ry: 22 },
  { id: 16, name: 'Triceps R', cx: 148, cy: 140, rx: 10, ry: 22 },
  { id: 17, name: 'Glutes', cx: 100, cy: 200, rx: 28, ry: 18 },
  { id: 18, name: 'Hamstrings', cx: 82, cy: 270, rx: 14, ry: 35 },
  { id: 19, name: 'Hamstrings R', cx: 118, cy: 270, rx: 14, ry: 35 },
  { id: 20, name: 'Lower Back', cx: 100, cy: 165, rx: 22, ry: 15 },
];

interface BodySilhouetteProps {
  view: 'front' | 'back';
  sorenessMap?: Map<string, number>; // muscle name → 0-4
  selectedMuscle?: string | null;
  onMuscleClick?: (muscleName: string, muscleId: number) => void;
}

export function BodySilhouette({ view, sorenessMap, selectedMuscle, onMuscleClick }: BodySilhouetteProps) {
  const muscles = view === 'front' ? FRONT_MUSCLES : BACK_MUSCLES;

  return (
    <Box sx={{ width: '100%', maxWidth: 160, mx: 'auto' }}>
      <svg viewBox="0 0 200 400" width="100%" height="100%">
        {/* Body outline */}
        <ellipse cx="100" cy="30" rx="22" ry="28" fill="#2A2A3E" stroke="#444" strokeWidth="1" />
        <rect x="72" y="55" width="56" height="5" rx="2" fill="#2A2A3E" />
        <path
          d={view === 'front'
            ? 'M72,60 L55,70 L40,130 L42,200 L56,200 L60,170 L68,200 L68,310 L62,370 L62,395 L80,395 L85,370 L88,310 L88,200 L112,200 L112,310 L115,370 L120,395 L138,395 L138,370 L132,310 L132,200 L140,170 L144,200 L158,200 L160,130 L145,70 L128,60 Z'
            : 'M72,60 L55,70 L40,130 L42,200 L56,200 L60,170 L68,200 L68,310 L62,370 L62,395 L80,395 L85,370 L88,310 L88,200 L112,200 L112,310 L115,370 L120,395 L138,395 L138,370 L132,310 L132,200 L140,170 L144,200 L158,200 L160,130 L145,70 L128,60 Z'
          }
          fill="#2A2A3E"
          stroke="#444"
          strokeWidth="1"
        />

        {/* Muscle regions */}
        {muscles.map((muscle) => {
          const baseName = muscle.name.replace(' R', '');
          const level = sorenessMap?.get(baseName) ?? 0;
          const isSelected = selectedMuscle === baseName;

          return (
            <ellipse
              key={muscle.id}
              cx={muscle.cx}
              cy={muscle.cy}
              rx={muscle.rx}
              ry={muscle.ry}
              fill={level > 0 ? `${SORENESS_COLORS[level]}40` : isSelected ? 'rgba(168, 199, 250, 0.3)' : 'rgba(168, 199, 250, 0.08)'}
              stroke={isSelected ? '#A8C7FA' : level > 0 ? SORENESS_COLORS[level] : 'rgba(168, 199, 250, 0.2)'}
              strokeWidth={isSelected ? 2 : 1}
              style={{ cursor: onMuscleClick ? 'pointer' : 'default' }}
              onClick={() => onMuscleClick?.(baseName, muscle.id)}
            />
          );
        })}
      </svg>
    </Box>
  );
}
