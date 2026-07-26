<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class RoomController extends Controller
{
    /**
     * Display a listing of the rooms for a hotel.
     */
    public function index(Request $request, $hotelId = null)
    {
        $query = Room::with('hotel');

        if ($hotelId) {
            $query->where('hotel_id', $hotelId);
            $hotel = Hotel::find($hotelId);
        } else {
            $hotel = null;
        }

        // Filter by room type
        if ($request->has('type') && $request->type !== '') {
            $query->where('room_type', $request->type);
        }

        // Filter by availability
        if ($request->has('availability') && $request->availability !== '') {
            $query->where('is_available', $request->availability === 'available');
        }

        $rooms = $query->latest()->paginate(10);
        
        $roomTypes = ['standard', 'deluxe', 'suite', 'family', 'presidential'];
        
        return view('admin.rooms.index', compact('rooms', 'hotel', 'roomTypes'));
    }

    /**
     * Show the form for creating a new room.
     */
    public function create(Request $request)
    {
        $hotels = Hotel::all();
        $selectedHotel = $request->hotel_id ? Hotel::find($request->hotel_id) : null;
        $roomTypes = ['standard', 'deluxe', 'suite', 'family', 'presidential'];
        $bedTypes = ['single', 'double', 'twin', 'queen', 'king'];
        $facilitiesList = [
            'AC', 'TV', 'WiFi', 'Mini Bar', 'Bathtub', 'Shower', 
            'Balcony', 'Sea View', 'City View', 'Garden View', 'Pool View'
        ];
        
        return view('admin.rooms.create', compact('hotels', 'selectedHotel', 'roomTypes', 'bedTypes', 'facilitiesList'));
    }

    /**
     * Store a newly created room in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'hotel_id' => 'required|exists:hotels,id',
            'room_number' => 'required|string|max:20|unique:rooms,room_number',
            'room_type' => 'required|in:standard,deluxe,suite,family,presidential',
            'room_name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'price_per_night' => 'required|integer|min:0',
            'capacity' => 'required|integer|min:1',
            'bed_type' => 'required|in:single,double,twin,queen,king',
            'size' => 'nullable|integer|min:0',
            'facilities' => 'nullable|array',
            'thumbnail' => 'nullable|image|max:2048', // Max 2MB
            'images.*' => 'nullable|image|max:2048', // Multiple images
            'is_available' => 'boolean'
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Handle thumbnail upload
        $thumbnail = null;
        if ($request->hasFile('thumbnail')) {
            $thumbnail = $this->uploadImage($request->file('thumbnail'));
        }

        // Handle multiple images upload
        $images = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                if ($image->isValid()) {
                    $images[] = $this->uploadImage($image);
                }
            }
        }

        $room = Room::create([
            'hotel_id' => $request->hotel_id,
            'room_number' => $request->room_number,
            'room_type' => $request->room_type,
            'room_name' => $request->room_name,
            'description' => $request->description,
            'price_per_night' => $request->price_per_night,
            'capacity' => $request->capacity,
            'bed_type' => $request->bed_type,
            'size' => $request->size,
            'facilities' => $request->facilities,
            'thumbnail' => $thumbnail,
            'images' => !empty($images) ? $images : null,
            'is_available' => $request->has('is_available')
        ]);

        return redirect()->route('admin.rooms.index', ['hotel_id' => $request->hotel_id])
            ->with('success', 'Kamar berhasil ditambahkan!');
    }

    /**
     * Display the specified room.
     */
    public function show($id)
    {
        $room = Room::with(['hotel', 'roomBookings'])->findOrFail($id);
        return view('admin.rooms.show', compact('room'));
    }

    /**
     * Show the form for editing the specified room.
     */
    public function edit($id)
    {
        $room = Room::findOrFail($id);
        $hotels = Hotel::all();
        $roomTypes = ['standard', 'deluxe', 'suite', 'family', 'presidential'];
        $bedTypes = ['single', 'double', 'twin', 'queen', 'king'];
        $facilitiesList = [
            'AC', 'TV', 'WiFi', 'Mini Bar', 'Bathtub', 'Shower', 
            'Balcony', 'Sea View', 'City View', 'Garden View', 'Pool View'
        ];
        
        return view('admin.rooms.edit', compact('room', 'hotels', 'roomTypes', 'bedTypes', 'facilitiesList'));
    }

    /**
     * Update the specified room in storage.
     */
     public function update(Request $request, $id)
    {
        $room = Room::findOrFail($id);

        // Log untuk debugging
        Log::info('Room update request', [
            'all' => $request->all(),
            'has_thumbnail' => $request->hasFile('thumbnail'),
            'has_images' => $request->hasFile('images')
        ]);

        $validator = Validator::make($request->all(), [
            'hotel_id' => 'required|exists:hotels,id',
            'room_number' => 'required|string|max:20|unique:rooms,room_number,' . $id,
            'room_type' => 'required|in:standard,deluxe,suite,family,presidential',
            'room_name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'price_per_night' => 'required|integer|min:0',
            'capacity' => 'required|integer|min:1',
            'bed_type' => 'required|in:single,double,twin,queen,king',
            'size' => 'nullable|integer|min:0',
            'facilities' => 'nullable|array',
            'thumbnail' => 'nullable|file|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'images.*' => 'nullable|file|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'is_available' => 'boolean',
            'delete_images' => 'nullable|array' // Tambahkan validasi
        ]);

        if ($validator->fails()) {
            Log::error('Room update validation failed', [
                'errors' => $validator->errors()->toArray()
            ]);
            
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $data = [
            'hotel_id' => $request->hotel_id,
            'room_number' => $request->room_number,
            'room_type' => $request->room_type,
            'room_name' => $request->room_name,
            'description' => $request->description,
            'price_per_night' => $request->price_per_night,
            'capacity' => $request->capacity,
            'bed_type' => $request->bed_type,
            'size' => $request->size,
            'facilities' => $request->facilities,
            'is_available' => $request->has('is_available')
        ];

        // Handle thumbnail upload
        if ($request->hasFile('thumbnail')) {
            $file = $request->file('thumbnail');
            
            Log::info('Thumbnail file info', [
                'name' => $file->getClientOriginalName(),
                'size' => $file->getSize(),
                'mime' => $file->getMimeType(),
                'extension' => $file->getClientOriginalExtension(),
                'is_valid' => $file->isValid()
            ]);
            
            // Delete old thumbnail
            if ($room->thumbnail) {
                Storage::disk('public')->delete('rooms/' . $room->thumbnail);
            }
            
            $data['thumbnail'] = $this->uploadImage($file);
        }

        // Handle multiple images upload
        if ($request->hasFile('images')) {
            $newImages = [];
            foreach ($request->file('images') as $file) {
                if ($file->isValid()) {
                    $newImages[] = $this->uploadImage($file);
                }
            }
            
            // Merge with existing images
            $existingImages = $room->images ?? [];
            $data['images'] = array_merge($existingImages, $newImages);
        }

        // Handle delete images - PERBAIKAN
        if ($request->has('delete_images')) {
            try {
                $deleteImages = $request->delete_images;
                
                // Jika delete_images adalah array, gunakan langsung
                if (is_array($deleteImages)) {
                    // Filter null values
                    $deleteImages = array_filter($deleteImages, function($value) {
                        return !is_null($value) && $value !== '';
                    });
                } 
                // Jika delete_images adalah string JSON, decode
                elseif (is_string($deleteImages)) {
                    $deleteImages = json_decode($deleteImages, true);
                    if (!is_array($deleteImages)) {
                        $deleteImages = [];
                    }
                } 
                // Jika null atau kosong
                else {
                    $deleteImages = [];
                }
                
                // Proses delete images
                if (!empty($deleteImages)) {
                    $currentImages = $room->images ?? [];
                    $remainingImages = array_diff($currentImages, $deleteImages);
                    
                    // Delete files from storage
                    foreach ($deleteImages as $image) {
                        if ($image && Storage::disk('public')->exists('rooms/' . $image)) {
                            Storage::disk('public')->delete('rooms/' . $image);
                            Log::info('Image deleted: ' . $image);
                        }
                    }
                    
                    $data['images'] = !empty($remainingImages) ? array_values($remainingImages) : null;
                }
            } catch (\Exception $e) {
                Log::error('Error deleting images: ' . $e->getMessage());
                // Jika error, biarkan images tetap sama
            }
        }

        $room->update($data);

        return redirect()->route('admin.rooms.index', ['hotel_id' => $room->hotel_id])
            ->with('success', 'Kamar berhasil diperbarui!');
    }

    /**
     * Remove the specified room from storage.
     */
    public function destroy($id)
    {
        $room = Room::findOrFail($id);
        
        // Cek apakah kamar sudah ada booking
        if ($room->roomBookings()->count() > 0) {
            return redirect()->back()
                ->with('error', 'Kamar sudah memiliki booking dan tidak dapat dihapus!');
        }

        // Delete images
        if ($room->thumbnail) {
            Storage::disk('public')->delete('rooms/' . $room->thumbnail);
        }
        if ($room->images) {
            foreach ($room->images as $image) {
                Storage::disk('public')->delete('rooms/' . $image);
            }
        }

        $hotelId = $room->hotel_id;
        $room->delete();

        return redirect()->route('admin.rooms.index', ['hotel_id' => $hotelId])
            ->with('success', 'Kamar berhasil dihapus!');
    }

    /**
     * Toggle room availability
     */
    public function toggleAvailability($id)
    {
        $room = Room::findOrFail($id);
        $room->update(['is_available' => !$room->is_available]);

        $status = $room->is_available ? 'tersedia' : 'tidak tersedia';
        return redirect()->back()
            ->with('success', "Kamar berhasil diubah menjadi {$status}!");
    }


     /**
     * Upload image helper
     */
    private function uploadImage($file)
    {
         try {
            // Generate unique filename
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            
            // Store file
            $path = $file->storeAs('rooms', $filename, 'public');
            
            Log::info('Image uploaded successfully', [
                'filename' => $filename,
                'path' => $path
            ]);
            
            return $filename;
        } catch (\Exception $e) {
            Log::error('Error uploading image: ' . $e->getMessage());
            return null;
        }
    }
}