@extends('admin.layouts.admin')

@section('title', 'Edit Hotel - ' . $hotel->name)

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.hotels.index') }}" class="text-blue-600 hover:text-blue-800">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
            </svg>
        </a>
        <h1 class="text-xl font-bold text-gray-900">✏️ Edit Hotel - {{ $hotel->name }}</h1>
    </div>

    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            {{ session('error') }}
        </div>
    @endif

    @if($errors->any())
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            <ul class="list-disc pl-4">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('admin.hotels.update', $hotel->id) }}" class="space-y-6" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Name -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nama Hotel <span class="text-red-500">*</span>
                </label>
                <input type="text" name="name" value="{{ old('name', $hotel->name) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('name') border-red-500 @enderror"
                       required>
                @error('name')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Location -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Lokasi / Kota <span class="text-red-500">*</span>
                </label>
                <input type="text" name="location" value="{{ old('location', $hotel->location) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('location') border-red-500 @enderror"
                       required>
                @error('location')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Rating -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Rating
                </label>
                <input type="number" step="0.1" name="rating" value="{{ old('rating', $hotel->rating) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('rating') border-red-500 @enderror"
                       placeholder="Contoh: 4.5" min="0" max="5">
                <p class="text-xs text-gray-400 mt-1">Isi dengan angka 0-5 (contoh: 4.5)</p>
                @error('rating')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Phone -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nomor Telepon
                </label>
                <input type="text" name="phone" value="{{ old('phone', $hotel->phone) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('phone') border-red-500 @enderror"
                       placeholder="081234567890">
                @error('phone')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Email -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Email
                </label>
                <input type="email" name="email" value="{{ old('email', $hotel->email) }}" 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('email') border-red-500 @enderror"
                       placeholder="hotel@email.com">
                @error('email')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>

            <!-- Check-in/Check-out -->
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">
                    Jam Check-in / Check-out
                </label>
                <div class="flex gap-2">
                    <input type="time" name="check_in_time" value="{{ old('check_in_time', $hotel->check_in_time ?? '14:00') }}" 
                           class="w-1/2 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('check_in_time') border-red-500 @enderror">
                    <span class="text-sm text-gray-500 self-center">/</span>
                    <input type="time" name="check_out_time" value="{{ old('check_out_time', $hotel->check_out_time ?? '12:00') }}" 
                           class="w-1/2 rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('check_out_time') border-red-500 @enderror">
                </div>
                <p class="text-xs text-gray-400 mt-1">Format: HH:MM (24 jam)</p>
                @error('check_in_time')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
                @error('check_out_time')
                    <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
                @enderror
            </div>
        </div>

        <!-- Address -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Alamat Lengkap
            </label>
            <textarea name="address" rows="2" 
                      class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('address') border-red-500 @enderror"
                      placeholder="Jl. Contoh No. 123, Kota">{{ old('address', $hotel->address) }}</textarea>
            @error('address')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Description -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Deskripsi Hotel
            </label>
            <textarea name="description" rows="4" 
                      class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('description') border-red-500 @enderror"
                      placeholder="Tulis fasilitas dan detail hotel...">{{ old('description', $hotel->description) }}</textarea>
            @error('description')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Facilities -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Fasilitas Hotel</label>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-2 p-3 border border-gray-200 rounded-lg">
                @php
                    $facilities = ['WiFi', 'Parkir', 'Kolam Renang', 'Restoran', 'Gym', 'Spa', 'AC', 'TV', 'Room Service', 'Laundry'];
                    $selectedFacilities = old('facilities', $hotel->facilities ?? []);
                @endphp
                @foreach($facilities as $facility)
                    <label class="flex items-center gap-2 text-sm">
                        <input type="checkbox" name="facilities[]" value="{{ $facility }}"
                               {{ in_array($facility, $selectedFacilities) ? 'checked' : '' }}
                               class="rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                        {{ $facility }}
                    </label>
                @endforeach
            </div>
            @error('facilities')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Photo -->
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
                Foto Hotel
            </label>
            @if($hotel->image)
                <div class="mb-2">
                    <p class="text-xs text-gray-500 mb-1">Foto Saat Ini:</p>
                    <img src="{{ asset('storage/hotels/' . $hotel->image) }}" 
                         alt="{{ $hotel->name }}" 
                         class="h-20 w-20 object-cover rounded-lg border border-gray-200">
                </div>
            @endif
            <input type="file" name="image" id="image"
                   class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none @error('image') border-red-500 @enderror"
                   accept="image/*">
            <p class="text-xs text-gray-400 mt-1">Upload foto baru untuk mengganti foto lama</p>
            <div id="imagePreview" class="mt-2 hidden">
                <img id="imagePreviewImg" class="h-20 w-20 object-cover rounded-lg border border-gray-200">
            </div>
            @error('image')
                <p class="text-xs text-red-500 mt-1">{{ $message }}</p>
            @enderror
        </div>

        <!-- Submit -->
        <div class="flex gap-3 pt-4 border-t border-gray-200">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg text-sm font-medium transition">
                Update Hotel
            </button>
            <a href="{{ route('admin.hotels.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-medium transition">
                Kembali
            </a>
        </div>
    </form>
</div>

<script>
    // Image preview
    document.getElementById('image')?.addEventListener('change', function(e) {
        const file = e.target.files[0];
        const preview = document.getElementById('imagePreview');
        const img = document.getElementById('imagePreviewImg');
        
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
</script>
@endsection