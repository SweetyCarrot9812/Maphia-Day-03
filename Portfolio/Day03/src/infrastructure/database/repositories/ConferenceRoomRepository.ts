/**
 * @SPEC:REPO-001 Conference Room Repository Implementation
 * Handles data persistence for conference rooms using Supabase
 */
import { supabase } from '../supabase';
import { ConferenceRoom, ConferenceRoomProps } from '../../../domain/entities/ConferenceRoom';
import { Repository, Result } from '../../../domain/types/common';

export class ConferenceRoomRepository implements Repository<ConferenceRoom> {
  async findById(id: string): Promise<Result<ConferenceRoom>> {
    try {
      const { data, error } = await supabase
        .from('conference_rooms')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      if (!data) {
        return { success: false, error: new Error('Conference room not found') };
      }

      const conferenceRoom = new ConferenceRoom({
        id: data.id,
        name: data.name,
        capacity: data.capacity,
        amenities: data.amenities || [],
        isActive: data.is_active,
        createdAt: new Date(data.created_at),
        updatedAt: new Date(data.updated_at),
      });

      return { success: true, data: conferenceRoom };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async findAll(): Promise<Result<ConferenceRoom[]>> {
    try {
      const { data, error } = await supabase
        .from('conference_rooms')
        .select('*')
        .eq('is_active', true)
        .order('name');

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const conferenceRooms = data.map(room => new ConferenceRoom({
        id: room.id,
        name: room.name,
        capacity: room.capacity,
        amenities: room.amenities || [],
        isActive: room.is_active,
        createdAt: new Date(room.created_at),
        updatedAt: new Date(room.updated_at),
      }));

      return { success: true, data: conferenceRooms };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async save(conferenceRoom: ConferenceRoom): Promise<Result<ConferenceRoom>> {
    try {
      const roomData = {
        id: conferenceRoom.id,
        name: conferenceRoom.name,
        capacity: conferenceRoom.capacity,
        amenities: conferenceRoom.amenities,
        is_active: conferenceRoom.isActive,
        updated_at: new Date().toISOString(),
      };

      const { data, error } = await supabase
        .from('conference_rooms')
        .upsert(roomData)
        .select()
        .single();

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const savedRoom = new ConferenceRoom({
        id: data.id,
        name: data.name,
        capacity: data.capacity,
        amenities: data.amenities || [],
        isActive: data.is_active,
        createdAt: new Date(data.created_at),
        updatedAt: new Date(data.updated_at),
      });

      return { success: true, data: savedRoom };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async delete(id: string): Promise<Result<void>> {
    try {
      const { error } = await supabase
        .from('conference_rooms')
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      return { success: true, data: undefined };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async findByCapacity(minCapacity: number): Promise<Result<ConferenceRoom[]>> {
    try {
      const { data, error } = await supabase
        .from('conference_rooms')
        .select('*')
        .eq('is_active', true)
        .gte('capacity', minCapacity)
        .order('capacity');

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const conferenceRooms = data.map(room => new ConferenceRoom({
        id: room.id,
        name: room.name,
        capacity: room.capacity,
        amenities: room.amenities || [],
        isActive: room.is_active,
        createdAt: new Date(room.created_at),
        updatedAt: new Date(room.updated_at),
      }));

      return { success: true, data: conferenceRooms };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }
}