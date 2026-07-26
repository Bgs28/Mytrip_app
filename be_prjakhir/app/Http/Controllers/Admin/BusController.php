<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class BusController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = Bus::query();

        // Search
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('bus_name', 'LIKE', "%{$search}%")
                  ->orWhere('from', 'LIKE', "%{$search}%")
                  ->orWhere('destination', 'LIKE', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->has('status') && $request->status != '') {
            $query->where('status', $request->status);
        }

        $buses = $query->latest()->paginate(10);
        
        return view('admin.buses.index', compact('buses'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $defaultTimes = ['07:00', '11:00', '15:00', '17:00'];
        return view('admin.buses.create', compact('defaultTimes'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            Log::info('Bus store request', $request->all());

            $validator = Validator::make($request->all(), [
                'bus_name' => 'required|string|max:100',
                'from' => 'required|string|max:100',
                'destination' => 'required|string|max:100',
                'price' => 'required|integer|min:0',
                'seat' => 'required|integer|min:1',
                'departure_times' => 'required|array|min:1',
                'departure_times.*' => 'string|date_format:H:i',
                'duration_minutes' => 'required|integer|min:1',
                'start_date' => 'required|date|after_or_equal:today',
                'end_date' => 'required|date|after_or_equal:start_date',
            ]);

            if ($validator->fails()) {
                Log::warning('Bus validation failed', ['errors' => $validator->errors()->toArray()]);
                return redirect()->back()
                    ->withErrors($validator)
                    ->withInput();
            }

            // Prepare data
            $data = $request->all();
            $data['departure_times'] = json_encode($request->departure_times);
            $data['status'] = $request->has('status') ? 'active' : 'inactive';

            Log::info('Creating bus with data', $data);

            // Create bus
            $bus = Bus::create($data);

            Log::info('Bus created successfully', ['bus_id' => $bus->id]);

            return redirect()->route('admin.buses.index')
                ->with('success', 'Bus berhasil ditambahkan! Jadwal dan kursi telah digenerate otomatis.');

        } catch (\Exception $e) {
            Log::error('Error creating bus: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $bus = Bus::with(['schedules', 'seats'])->findOrFail($id);
        return view('admin.buses.show', compact('bus'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit($id)
    {
        $bus = Bus::findOrFail($id);
        $defaultTimes = ['07:00', '11:00', '15:00', '17:00'];
        return view('admin.buses.edit', compact('bus', 'defaultTimes'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        try {
            $bus = Bus::findOrFail($id);

            Log::info('Bus update request', ['id' => $id, 'data' => $request->all()]);

            $validator = Validator::make($request->all(), [
                'bus_name' => 'required|string|max:100',
                'from' => 'required|string|max:100',
                'destination' => 'required|string|max:100',
                'price' => 'required|integer|min:0',
                'seat' => 'required|integer|min:1',
                'departure_times' => 'required|array|min:1',
                'departure_times.*' => 'string|date_format:H:i',
                'duration_minutes' => 'required|integer|min:1',
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date',
            ]);

            if ($validator->fails()) {
                Log::warning('Bus update validation failed', ['errors' => $validator->errors()->toArray()]);
                return redirect()->back()
                    ->withErrors($validator)
                    ->withInput();
            }

            // Prepare data
            $data = $request->all();
            $data['departure_times'] = json_encode($request->departure_times);
            $data['status'] = $request->has('status') ? 'active' : 'inactive';

            // Update bus
            $bus->update($data);

            Log::info('Bus updated successfully', ['bus_id' => $bus->id]);

            return redirect()->route('admin.buses.index')
                ->with('success', 'Bus berhasil diperbarui! Jadwal dan kursi telah diupdate.');

        } catch (\Exception $e) {
            Log::error('Error updating bus: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        try {
            $bus = Bus::findOrFail($id);
            
            // Hapus semua relasi
            $bus->schedules()->delete();
            $bus->seats()->delete();
            
            $bus->delete();

            return redirect()->route('admin.buses.index')
                ->with('success', 'Bus berhasil dihapus!');

        } catch (\Exception $e) {
            Log::error('Error deleting bus: ' . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }
}