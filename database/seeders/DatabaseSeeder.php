<?php

namespace Database\Seeders;

use App\Models\Account;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use App\Models\Contact;
use App\Models\Organization;
use App\Models\Shop;
use App\Models\ShopList;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {

        // Shop::factory(2)
        //     ->create();
        Shop::factory(2)
            ->create()->each(function ($shop) {
                ShopList::factory(rand(1,10))
                    ->create();
            });
    }
}
