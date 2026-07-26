@extends('admin.layouts.admin')

@section('title', 'Tambah Kamar Hotel')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.rooms.index', ['hotel_id' => $selectedHotel?->id]) }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">🛏️ Tambah Kamar Hotel</h1>
    </div>

    <form method="POST" action="{{ route('admin.rooms.store') }}" class="space-y-6" enctype="multipart/form-data">
        @csrf

        <!-- Hotel Selection -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Pilih Hotel <span class="text-red-500">*</span>
            </label>
            <select name="hotel_id" id="hotel_id"
                    class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('hotel_id') border-red-500 @enderror"
                    required>
                <option value="">-- Pilih Hotel --</option>
                @foreach($hotels as $hotel)
                    <option value="{{ $hotel->id }}" {{ old('hotel_id', $selectedHotel?->id) == $hotel->id ? 'selected' : '' }}>
                        {{ $hotel->name }} - {{ $hotel->location }}
                    </option>
                @endforeach
            </select>
            @error('hotel_id')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Room Number -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nomor Kamar <span class="text-red-500">*</span>
                </label>
                <input type="text" name="room_number" value="{{ old('room_number') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('room_number') border-red-500 @enderror"
                       placeholder="101" required>
                @error('room_number')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Room Name -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nama Kamar <span class="text-red-500">*</span>
                </label>
                <input type="text" name="room_name" value="{{ old('room_name') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('room_name') border-red-500 @enderror"
                       placeholder="Deluxe Ocean View" required>
                @error('room_name')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Room Type -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Tipe Kamar <span class="text-red-500">*</span>
                </label>
                <select name="room_type" 
                        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('room_type') border-red-500 @enderror"
                        required>
                    <option value="">-- Pilih Tipe --</option>
                    @foreach($roomTypes as $type)
                        <option value="{{ $type }}" {{ old('room_type') == $type ? 'selected' : '' }}>
                            {{ ucfirst($type) }}
                        </option>
                    @endforeach
                </select>
                @error('room_type')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Price Per Night -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Harga per Malam <span class="text-red-500">*</span>
                </label>
                <input type="number" name="price_per_night" value="{{ old('price_per_night') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('price_per_night') border-red-500 @enderror"
                       placeholder="500000" required>
                @error('price_per_night')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Capacity -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Kapasitas <span class="text-red-500">*</span>
                </label>
                <input type="number" name="capacity" value="{{ old('capacity', 2) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('capacity') border-red-500 @enderror"
                       min="1" required>
                @error('capacity')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Bed Type -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Tipe Tempat Tidur <span class="text-red-500">*</span>
                </label>
                <select name="bed_type" 
                        class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('bed_type') border-red-500 @enderror"
                        required>
                    <option value="">-- Pilih Tipe --</option>
                    @foreach($bedTypes as $bed)
                        <option value="{{ $bed }}" {{ old('bed_type') == $bed ? 'selected' : '' }}>
                            {{ ucfirst(str_replace('_', ' ', $bed)) }}
                        </option>
                    @endforeach
                </select>
                @error('bed_type')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Size -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Ukuran Kamar (m²)</label>
                <input type="number" name="size" value="{{ old('size') }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('size') border-red-500 @enderror"
                       placeholder="25">
                @error('size')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Description -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi Kamar</label>
            <textarea name="description" rows="3" 
                      class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('description') border-red-500 @enderror"
                      placeholder="Deskripsi fasilitas kamar...">{{ old('description') }}</textarea>
            @error('description')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Facilities -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Fasilitas Kamar</label>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-2 p-3 border border-gray-200 rounded-lg">
                @foreach($facilitiesList as $facility)
                    <label class="flex items-center gap-2 text-sm">
                        <input type="checkbox" name="facilities[]" value="{{ $facility }}"
                               {{ in_array($facility, old('facilities', [])) ? 'checked' : '' }}
                               class="rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                        {{ $facility }}
                    </label>
                @endforeach
            </div>
            @error('facilities')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Upload Gambar -->
        <div class="border-t border-gray-200 pt-6">
            <h3 class="font-semibold text-gray-900 mb-4">🖼️ Gambar Kamar</h3>
            
            <!-- Thumbnail -->
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Thumbnail (Gambar Utama)
                </label>
                <input type="file" name="thumbnail" id="thumbnail"
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('thumbnail') border-red-500 @enderror"
                       accept="image/*">
                <div id="thumbnailPreview" class="mt-2 hidden">
                    <img id="thumbnailPreviewImg" class="h-32 w-32 object-cover rounded-lg border border-gray-200">
                </div>
                @error('thumbnail')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Multiple Images -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Gambar Tambahan (Multiple)
                </label>
                <input type="file" name="images[]" id="images" multiple
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('images.*') border-red-500 @enderror"
                       accept="image/*">
                <div id="imagesPreview" class="mt-2 flex flex-wrap gap-2"></div>
                @error('images.*')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Is Available -->
        <div class="flex items-center gap-2">
            <input type="checkbox" name="is_available" value="1" {{ old('is_available', true) ? 'checked' : '' }}
                   class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
            <label class="text-sm font-medium text-gray-700">Kamar Tersedia</label>
        </div>

        <!-- Submit -->
        <div class="flex gap-3 pt-4 border-t border-gray-200">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm font-medium transition">
                Simpan Kamar
            </button>
            <a href="{{ route('admin.rooms.index', ['hotel_id' => $selectedHotel?->id]) }}" 
               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-medium transition">
                Batal
            </a>
        </div>
    </form>
</div>

<script>
    // Thumbnail preview - FIX
    document.getElementById('thumbnail').addEventListener('change', function(e) {
        const file = e.target.files[0];
        const preview = document.getElementById('thumbnailPreview');
        const img = document.getElementById('thumbnailPreviewImg');
        
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                img.src = e.target.result;
                preview.classList.remove('hidden');
            }
            reader.readAsDataURL(file);
        } else {
            preview.classList.add('hidden');
            img.src = '';
        }
    });

    // Multiple images preview - FIX
    document.getElementById('images').addEventListener('change', function(e) {
        const preview = document.getElementById('imagesPreview');
        preview.innerHTML = '';
        const files = e.target.files;
        
        if (files.length === 0) {
            preview.innerHTML = '<p class="text-sm text-gray-400">Belum ada gambar yang dipilih</p>';
            return;
        }
        
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const reader = new FileReader();
            reader.onload = function(e) {
                const div = document.createElement('div');
                div.className = 'relative group inline-block';
                div.innerHTML = `
                    <img src="${e.target.result}" class="h-20 w-20 object-cover rounded-lg border border-gray-200">
                    <button type="button" onclick="removePreviewImage(this)" 
                            class="absolute -top-1 -right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs hover:bg-red-600">
                        ×
                    </button>
                `;
                preview.appendChild(div);
            }
            reader.readAsDataURL(file);
        }
    });

    function removePreviewImage(btn) {
        const parent = btn.parentElement;
        parent.remove();
        // Update file input (clear all files if no previews left)
        const previewContainer = document.getElementById('imagesPreview');
        if (previewContainer.children.length === 0) {
            document.getElementById('images').value = '';
            previewContainer.innerHTML = '<p class="text-sm text-gray-400">Belum ada gambar yang dipilih</p>';
        }
    }

    // Auto-fill room name based on room type
    document.getElementById('room_type')?.addEventListener('change', function() {
        const roomName = document.querySelector('input[name="room_name"]');
        if (!roomName.value || roomName.dataset.auto === 'true') {
            const typeMap = {
                'standard': 'Standard Room',
                'deluxe': 'Deluxe Room',
                'suite': 'Suite Room',
                'family': 'Family Room',
                'presidential': 'Presidential Suite'
            };
            if (this.value && typeMap[this.value]) {
                roomName.value = typeMap[this.value];
                roomName.dataset.auto = 'true';
            }
        }
    });
</script>
@endsection