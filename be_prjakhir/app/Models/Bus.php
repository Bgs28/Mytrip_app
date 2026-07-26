<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

class Bus extends Model
{
    protected $fillable = [
        'bus_name',
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

    // Relasi ke BusSeat
    public function seats()
    {
        return $this->hasMany(BusSeat::class);
    }

    // Relasi ke BusSchedule
    public function schedules()
    {
        return $this->hasMany(BusSchedule::class);
    }

    // Relasi ke Booking
    // public function bookings()
    // {
    //     return $this->hasMany(Booking::class);
    // }

    // Generate seats otomatis saat bus dibuat
    public static function boot()
    {
        parent::boot();

        static::created(function ($bus) {
            $bus->generateSeats();
            $bus->generateSchedules();
        });

        static::updated(function ($bus) {
            if ($bus->isDirty('seat')) {
                $bus->seats()->delete();
                $bus->generateSeats();
            }
            
            if ($bus->isDirty(['departure_times', 'start_date', 'end_date'])) {
                $bus->schedules()->delete();
                $bus->generateSchedules();
            }
        });
    }

    // Generate seats dengan layout 2-2
    public function generateSeats()
{
    // Hapus semua kursi existing untuk bus ini
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
                'bus_id' => $this->id,
                'seat_number' => (string) $seatNumber,
                'seat_type' => 'regular',
                'position' => $positions[$col],
                'seat_code' => $seatCode,
                'is_available' => true,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }
    }
    
    if (!empty($seats)) {
        BusSeat::insert($seats);
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
                'bus_id' => $this->id,
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
        BusSchedule::insert($schedules);
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