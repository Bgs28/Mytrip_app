<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Train;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class TrainController extends Controller
{
    public function index(){
        $trains = Train::latest()->paginate(10);
        return view('admin.train.index', compact('trains'));
    }

    public function create(){
        return view('admin.train.create');
    }

    public function store(Request $request)
{
    try {
        Log::info('Train store request', $request->all());

        $validator = Validator::make($request->all(), [
            'train_name' => 'required|string|max:100',
            'from' => 'required|string|max:100',
            'destination' => 'required|string|max:100',
            'price' => 'required|integer|min:0',
            'seat' => 'required|integer|min:1',
            'departure_times' => 'required|array|min:1',
            'departure_times.*' => 'string|date_format:H:i',
            'duration_minutes' => 'required|integer|min:1',
            'start_date' => 'required|date|after_or_equal:today',
            'end_date' => 'required|date|after_or_equal:start_date',
            // HAPUS validasi status karena kita handle manual
        ]);

        if ($validator->fails()) {
            Log::warning('Train validation failed', ['errors' => $validator->errors()->toArray()]);
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Prepare data
        $data = $request->all();
        $data['departure_times'] = json_encode($request->departure_times);
        // Set status berdasarkan checkbox
        $data['status'] = $request->has('status') ? 'active' : 'inactive';

        Log::info('Creating train with data', $data);

        // Create train
        $train = Train::create($data);

        Log::info('Train created successfully', ['train_id' => $train->id]);

        return redirect()->route('admin.trains.index')
            ->with('success', 'Kereta berhasil ditambahkan! Jadwal dan kursi telah digenerate otomatis.');

    } catch (\Exception $e) {
        Log::error('Error creating train: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return redirect()->back()
            ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
            ->withInput();
    }
}


    public function edit($id){
        $train = Train::findOrFail($id);
        $defaultTimes = ['07:00', '11:00', '15:00', '17:00'];
        return view('admin.train.edit', compact('train', 'defaultTimes'));
    }

    public function update(Request $request, $id)
{
    try {
        $train = Train::findOrFail($id);

        Log::info('Train update request', ['id' => $id, 'data' => $request->all()]);

        $validator = Validator::make($request->all(), [
            'train_name' => 'required|string|max:100',
            'from' => 'required|string|max:100',
            'destination' => 'required|string|max:100',
            'price' => 'required|integer|min:0',
            'seat' => 'required|integer|min:1',
            'departure_times' => 'required|array|min:1',
            'departure_times.*' => 'string|date_format:H:i',
            'duration_minutes' => 'required|integer|min:1',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            // HAPUS validasi status
        ]);

        if ($validator->fails()) {
            Log::warning('Train update validation failed', ['errors' => $validator->errors()->toArray()]);
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Prepare data
        $data = $request->all();
        $data['departure_times'] = json_encode($request->departure_times);
        $data['status'] = $request->has('status') ? 'active' : 'inactive';

        // Update train
        $train->update($data);

        Log::info('Train updated successfully', ['train_id' => $train->id]);

        return redirect()->route('admin.trains.index')
            ->with('success', 'Kereta berhasil diperbarui! Jadwal dan kursi telah diupdate.');

    } catch (\Exception $e) {
        Log::error('Error updating train: ' . $e->getMessage());
        Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return redirect()->back()
            ->with('error', 'Terjadi kesalahan: ' . $e->getMessage())
            ->withInput();
    }
}

    public function destroy($id){
        $train = Train::findOrFail($id);
        $train->delete();

        return redirect()->route('admin.trains.index')->with('success', 'Data Kereta berhasil dihapus.');
    }
}
