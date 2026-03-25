import { useMutation } from '@tanstack/react-query';
import { supabase, API_BASE_URL } from '@/lib/supabase';

export interface MachineIdentificationResult {
  exercise_names: string[];
  equipment_type: string;
  manufacturer: string | null;
  target_muscles: {
    primary: string[];
    secondary: string[];
  };
  form_tips: string[];
  confidence: 'high' | 'medium' | 'low';
}

async function identifyMachine(file: File): Promise<MachineIdentificationResult> {
  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session?.access_token) {
    throw new Error('Not authenticated');
  }

  const apiBase = API_BASE_URL;

  const formData = new FormData();
  formData.append('image', file);

  const response = await fetch(`${apiBase}/api/ai/identify-machine`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${session.access_token}`,
    },
    body: formData,
  });

  if (!response.ok) {
    let detail = `Request failed with status ${response.status}`;
    try {
      const body = (await response.json()) as { detail?: string };
      if (body.detail) detail = body.detail;
    } catch {
      // ignore parse errors
    }
    throw new Error(detail);
  }

  return response.json() as Promise<MachineIdentificationResult>;
}

export function useMachineIdentify() {
  return useMutation<MachineIdentificationResult, Error, File>({
    mutationFn: identifyMachine,
  });
}
