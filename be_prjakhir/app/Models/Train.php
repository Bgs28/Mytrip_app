<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

class Train extends Model
{
    protected $fillable = [
        'train_name',
        'from',
        'destination',
        'price',
        'seat',
        'departure_times',
        'duration_minutes',
        'start_date',
        'end_date',
        'status'
    ];

    protected $casts = [
        'departure_times' => 'array',
        'start_date' => 'date',
        'end_date' => 'date',
        'duration_minutes' => 'integer'
    ];

    // Relasi ke TrainSeat
    public function seats()
    {
        return $this->hasMany(TrainSeat::class);
    }

    // Relasi ke TrainSchedule
    public function schedules()
    {
        return $this->hasMany(TrainSchedule::class);
    }

    // Relasi ke Booking
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Generate seats otomatis saat train dibuat
    public static function boot()
{
    parent::boot();

    static::created(function ($train) {
        Log::info('Train created, generating seats and schedules', ['train_id' => $train->id]);
        $train->generateSeats();
        $train->generateSchedules();
    });

    static::updated(function ($train) {
        Log::info('Train updated', ['train_id' => $train->id, 'dirty' => $train->getDirty()]);
        
        // Jika jumlah seat berubah, regenerate seats
        if ($train->isDirty('seat')) {
            Log::info('Seat count changed, regenerating seats', ['train_id' => $train->id]);
            $train->seats()->delete();
            $train->generateSeats();
        }
        
        // Jika jadwal berubah (departure_times, start_date, end_date, duration_minutes)
        if ($train->isDirty(['departure_times', 'start_date', 'end_date', 'duration_minutes'])) {
            Log::info('Schedule data changed, regenerating schedules', ['train_id' => $train->id]);
            $train->schedules()->delete();
            $train->generateSchedules();
        }
    });
}

    // Generate seats dengan layout 2-2
   public function generateSeats()
{
    // Hapus semua kursi existing untuk train ini
    $this->seats()->delete();
    
    $totalSeats = $this->seat;
    $seatsPerRow = 4;
    $rows = ceil($totalSeats / $seatsPerRow);
    
    $positions = ['window', 'aisle', 'aisle', 'window'];
    $seatNumbers = range(1, $totalSeats);
    
    $seats = [];
    for ($row = 1; $row <= $rows; $row++) {
        for ($col = 0; $col < $seatsPerRow; $col++) {
            $seatIndex = ($row - 1) * $seatsPerRow + $col;
            if ($seatIndex >= $totalSeats) break;
            
            $seatNumber = $seatNumbers[$seatIndex];
            $seatCode = chr(64 + $row) . ($col + 1);
            
            $seats[] = [
                'train_id' => $this->id,
                'seat_number' => (string) $seatNumber,
                'seat_class' => 'economy',
                'position' => $positions[$col],
                'seat_code' => $seatCode,
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }
    }
    
    if (!empty($seats)) {
        TrainSeat::insert($seats);
    }
}
    // Generate schedules untuk setiap tanggal di range
    public function generateSchedules()
{
   // Hapus jadwal existing terlebih dahulu
    $this->schedules()->delete();
    
    if (!$this->departure_times || !$this->start_date || !$this->end_date) {
        return;
    }

    $startDate = \Carbon\Carbon::parse($this->start_date);
    $endDate = \Carbon\Carbon::parse($this->end_date);
    $departureTimes = is_string($this->departure_times) ? json_decode($this->departure_times, true) : $this->departure_times;
    
    if (empty($departureTimes)) {
        return;
    }

    $schedules = [];
    $currentDate = clone $startDate;

    while ($currentDate <= $endDate) {
        foreach ($departureTimes as $time) {
            $departureTime = \Carbon\Carbon::parse($time);
            $arrivalTime = $departureTime->copy()->addMinutes($this->duration_minutes ?? 120);
            
            $schedules[] = [
                'train_id' => $this->id,
                'departure_date' => $currentDate->toDateString(),
                'departure_time' => $departureTime->format('H:i:s'),
                'arrival_time' => $arrivalTime->format('H:i:s'),
                'available_seats' => $this->seat ?? 40,
                'price' => $this->price ?? 0, // Tambahkan price
                'status' => 'active',
                'created_at' => now(),
                'updated_at' => now()
            ];
        }
        $currentDate->addDay();
    }

    if (!empty($schedules)) {
        TrainSchedule::insert($schedules);
    }
}

    // Get seat layout for display
    public function getSeatLayoutAttribute()
    {
        $seats = $this->seats()->orderBy('id')->get();
        $layout = [];
        $perRow = 4;
        
        foreach ($seats->chunk($perRow) as $rowIndex => $row) {
            $rowData = [];
            foreach ($row as $index => $seat) {
                $rowData[] = [
                    'seat_code' => $seat->seat_code,
                    'position' => $seat->position,
                    'is_available' => $seat->is_available,
                    'id' => $seat->id
                ];
            }
            while (count($rowData) < $perRow) {
                $rowData[] = null;
            }
            $layout[] = $rowData;
        }
        
        return $layout;
    }
}