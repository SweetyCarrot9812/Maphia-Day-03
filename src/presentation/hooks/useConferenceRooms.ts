/**
 * @SPEC:HOOKS-001 Conference Rooms API Hooks
 * TanStack Query hooks for conference room data fetching
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ConferenceRoomRepository } from '../../infrastructure/database/repositories/ConferenceRoomRepository';
import { ConferenceRoom } from '../../domain/entities/ConferenceRoom';

const conferenceRoomRepository = new ConferenceRoomRepository();

// Query keys
export const conferenceRoomKeys = {
  all: ['conference-rooms'] as const,
  lists: () => [...conferenceRoomKeys.all, 'list'] as const,
  list: (filters: Record<string, unknown>) => [...conferenceRoomKeys.lists(), filters] as const,
  details: () => [...conferenceRoomKeys.all, 'detail'] as const,
  detail: (id: string) => [...conferenceRoomKeys.details(), id] as const,
  byCapacity: (capacity: number) => [...conferenceRoomKeys.all, 'by-capacity', capacity] as const,
};

// Fetch all conference rooms
export function useConferenceRooms() {
  return useQuery({
    queryKey: conferenceRoomKeys.lists(),
    queryFn: async () => {
      const result = await conferenceRoomRepository.findAll();
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Fetch conference room by ID
export function useConferenceRoom(id: string) {
  return useQuery({
    queryKey: conferenceRoomKeys.detail(id),
    queryFn: async () => {
      const result = await conferenceRoomRepository.findById(id);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    enabled: !!id,
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
}

// Fetch conference rooms by capacity
export function useConferenceRoomsByCapacity(minCapacity: number) {
  return useQuery({
    queryKey: conferenceRoomKeys.byCapacity(minCapacity),
    queryFn: async () => {
      const result = await conferenceRoomRepository.findByCapacity(minCapacity);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    enabled: minCapacity > 0,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Create/Update conference room mutation
export function useCreateOrUpdateConferenceRoom() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (conferenceRoom: ConferenceRoom) => {
      const result = await conferenceRoomRepository.save(conferenceRoom);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    onSuccess: (data) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: conferenceRoomKeys.all });
      // Update specific room cache
      queryClient.setQueryData(conferenceRoomKeys.detail(data.id), data);
    },
  });
}

// Delete conference room mutation
export function useDeleteConferenceRoom() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const result = await conferenceRoomRepository.delete(id);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    onSuccess: (_, variables) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: conferenceRoomKeys.all });
      // Remove from cache
      queryClient.removeQueries({ queryKey: conferenceRoomKeys.detail(variables) });
    },
  });
}