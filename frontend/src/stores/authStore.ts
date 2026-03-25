import { create } from 'zustand';
import type { Session, User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';
import { indexedDBPersister } from '@/lib/offlinePersistence';

interface AuthState {
  user: User | null;
  session: Session | null;
  loading: boolean;
  error: string | null;
  sessionExpired: boolean;
  initialize: () => Promise<() => void>;
  signInWithEmail: (email: string, password: string) => Promise<void>;
  signUpWithEmail: (email: string, password: string) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  session: null,
  loading: true,
  error: null,
  sessionExpired: false,

  initialize: async () => {
    // Get initial session
    const {
      data: { session },
    } = await supabase.auth.getSession();
    set({
      user: session?.user ?? null,
      session: session ?? null,
      loading: false,
    });

    // Subscribe to auth state changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, session) => {
      // Detect unexpected session loss (token could not be refreshed) vs.
      // a deliberate sign-out initiated by the user via signOut().
      const isUnexpiredSignOut =
        (event === 'SIGNED_OUT' || (event === 'TOKEN_REFRESHED' && session == null)) &&
        useAuthStore.getState().user != null &&
        !useAuthStore.getState().loading;
      set({
        user: session?.user ?? null,
        session: session ?? null,
        loading: false,
        ...(isUnexpiredSignOut ? { sessionExpired: true } : {}),
      });
    });

    // Return cleanup function
    return () => subscription.unsubscribe();
  },

  signInWithEmail: async (email: string, password: string) => {
    set({ loading: true, error: null });
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      set({ loading: false, error: error.message });
      throw error;
    }
    set({ user: data.user, session: data.session, loading: false, error: null });
  },

  signUpWithEmail: async (email: string, password: string) => {
    set({ loading: true, error: null });
    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) {
      set({ loading: false, error: error.message });
      throw error;
    }
    set({ user: data.user, session: data.session, loading: false, error: null });
  },

  signInWithGoogle: async () => {
    set({ error: null });
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
      },
    });
    if (error) {
      set({ error: error.message });
      throw error;
    }
  },

  signOut: async () => {
    set({ loading: true, error: null });
    const { error } = await supabase.auth.signOut();
    if (error) {
      set({ loading: false, error: error.message });
      throw error;
    }
    // Clear persisted query cache (workout history, PII) on sign-out
    await indexedDBPersister.removeClient().catch(() => {});
    set({ user: null, session: null, loading: false, error: null, sessionExpired: false });
  },

  resetPassword: async (email: string) => {
    set({ error: null });
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/login`,
    });
    if (error) {
      set({ error: error.message });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
