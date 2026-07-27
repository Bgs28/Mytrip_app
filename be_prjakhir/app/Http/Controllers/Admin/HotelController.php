<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class HotelController extends Controller
{
    public function index()
    {
        // Menggunakan pagination agar rapi jika data banyak
        $hotels = Hotel::latest()->paginate(10);
        return view('admin.hotels.index', compact('hotels'));
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $hotel = Hotel::with('rooms')->findOrFail($id);
        return view('admin.hotels.show', compact('hotel'));
    }



    public function destroy($id)
    {
        $hotel = Hotel::findOrFail($id);
        
        if ($hotel->image) {
            Storage::disk('public')->delete($hotel->image);
        }
        
        $hotel->delete();

        return redirect()->route('admin.hotels.index')->with('success', 'Hotel berhasil dihapus!');
    }

    public function create()
    {
        return view('admin.hotels.create');
    }

    public function store(Request $request)
    {
        try {
            Log::info('Hotel store request', $request->all());

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:100',
                'location' => 'required|string|max:100',
                'description' => 'nullable|string',
                'rating' => 'nullable|numeric|min:0|max:5',
                'phone' => 'nullable|string|max:20',
                'email' => 'nullable|email|max:100',
                'address' => 'nullable|string',
                'check_in_time' => 'nullable|date_format:H:i',
                'check_out_time' => 'nullable|date_format:H:i',
                'facilities' => 'nullable|array',
                'image' => 'nullable|image|max:2048',
                'images.*' => 'nullable|image|max:2048'
            ]);

            if ($validator->fails()) {
                Log::warning('Hotel validation failed', ['errors' => $validator->errors()->toArray()]);
                return redirect()->back()
                    ->withErrors($validator)
                    ->withInput();
            }

            $data = $request->all();
            
            // Handle single image
            if ($request->hasFile('image')) {
                $data['image'] = $this->uploadImage($request->file('image'));
            }

            // Handle multiple images
            if ($request->hasFile('images')) {
                $images = [];
                foreach ($request->file('images') as $file) {
                    if ($file->isValid()) {
                        $images[] = $this->uploadImage($file);
                    }
                }
                $data['images'] = !empty($images) ? $images : null;
            }

            // Set default rating if not provided
            if (empty($data['rating'])) {
                $data['rating'] = 0;
            }

            $hotel = Hotel::create($data);

            Log::info('Hotel created successfully', ['hotel_id' => $hotel->id]);

            return redirect()->route('admin.hotels.index')
                ->with('success', 'Hotel berhasil ditambahkan!');

        } catch (\Exception $e) {
            Log::error('Error creating hotel: ' . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function edit($id)
    {
        $hotel = Hotel::findOrFail($id);
        return view('admin.hotels.edit', compact('hotel'));
    }

    public function update(Request $request, $id)
    {
        try {
            $hotel = Hotel::findOrFail($id);

            Log::info('Hotel update request', ['id' => $id, 'data' => $request->all()]);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:100',
                'location' => 'required|string|max:100',
                'description' => 'nullable|string',
                'rating' => 'nullable|numeric|min:0|max:5',
                'phone' => 'nullable|string|max:20',
                'email' => 'nullable|email|max:100',
                'address' => 'nullable|string',
                'check_in_time' => 'nullable|date_format:H:i',
                'check_out_time' => 'nullable|date_format:H:i',
                'facilities' => 'nullable|array',
                'image' => 'nullable|image|max:2048',
                'images.*' => 'nullable|image|max:2048'
            ]);

            if ($validator->fails()) {
                Log::warning('Hotel update validation failed', ['errors' => $validator->errors()->toArray()]);
                return redirect()->back()
                    ->withErrors($validator)
                    ->withInput();
            }

            $data = $request->all();

            // Handle single image
            if ($request->hasFile('image')) {
                if ($hotel->image) {
                    Storage::disk('public')->delete('hotels/' . $hotel->image);
                }
                $data['image'] = $this->uploadImage($request->file('image'));
            }

            // Handle multiple images
            if ($request->hasFile('images')) {
                $images = [];
                foreach ($request->file('images') as $file) {
                    if ($file->isValid()) {
                        $images[] = $this->uploadImage($file);
                    }
                }
                $existingImages = $hotel->images ?? [];
                $data['images'] = array_merge($existingImages, $images);
            }

            // Handle delete images
            if ($request->has('delete_images')) {
                $deleteImages = $request->delete_images;
                if (is_array($deleteImages)) {
                    $currentImages = $hotel->images ?? [];
                    $remainingImages = array_diff($currentImages, $deleteImages);
                    
                    foreach ($deleteImages as $image) {
                        if ($image && Storage::disk('public')->exists('hotels/' . $image)) {
                            Storage::disk('public')->delete('hotels/' . $image);
                        }
                    }
                    
                    $data['images'] = !empty($remainingImages) ? array_values($remainingImages) : null;
                }
            }

            $hotel->update($data);

            Log::info('Hotel updated successfully', ['hotel_id' => $hotel->id]);

            return redirect()->route('admin.hotels.index')
                ->with('success', 'Hotel berhasil diperbarui!');

        } catch (\Exception $e) {
            Log::error('Error updating hotel: ' . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
                ->withInput();
        }
    }

    private function uploadImage($file)
    {
        try {
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $file->storeAs('hotels', $filename, 'public');
            return $filename;
        } catch (\Exception $e) {
            Log::error('Error uploading image: ' . $e->getMessage());
            return null;
        }
    }
}