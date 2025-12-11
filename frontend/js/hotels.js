// Hotels Module
class Hotels {
    static async loadHotelsPage() {
        const container = document.getElementById('app-content');
        
        container.innerHTML = `
            <div class="row">
                <div class="col-12">
                    <h2 class="mb-4">
                        <i class="bi bi-building"></i> Доступные отели
                    </h2>
                </div>
            </div>
            
            <!-- Фильтры -->
            <div class="filter-section">
                <div class="row">
                    <div class="col-md-4">
                        <input type="text" class="form-control" id="city-filter" placeholder="Поиск по городу...">
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-primary" id="apply-filters">
                            <i class="bi bi-search"></i> Поиск
                        </button>
                        <button class="btn btn-secondary" id="reset-filters">
                            <i class="bi bi-arrow-clockwise"></i> Сбросить
                        </button>
                    </div>
                    <div class="col-md-5 text-end">
                        ${Auth.hasRole('system_admin') ? `
                            <button class="btn btn-success" id="add-hotel-btn">
                                <i class="bi bi-plus-circle"></i> Добавить отель
                            </button>
                        ` : ''}
                    </div>
                </div>
            </div>
            
            <!-- Список отелей -->
            <div class="row" id="hotels-list"></div>
        `;
        
        // Загрузить отели
        await this.loadHotels();
        
        // Обработчики событий
        document.getElementById('apply-filters').addEventListener('click', () => this.loadHotels());
        document.getElementById('reset-filters').addEventListener('click', () => {
            document.getElementById('city-filter').value = '';
            this.loadHotels();
        });
        
        if (Auth.hasRole('system_admin')) {
            document.getElementById('add-hotel-btn').addEventListener('click', () => this.showAddHotelModal());
        }
    }
    
    static async loadHotels() {
        const listContainer = document.getElementById('hotels-list');
        showSpinner(listContainer);
        
        try {
            const city = document.getElementById('city-filter').value;
            const params = city ? { city } : {};
            
            const hotels = await API.getHotels(params);
            
            if (hotels.length === 0) {
                listContainer.innerHTML = `
                    <div class="col-12">
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle"></i> Отели не найдены
                        </div>
                    </div>
                `;
                return;
            }
            
            listContainer.innerHTML = hotels.map(hotel => this.renderHotelCard(hotel)).join('');
            
        } catch (error) {
            showError(listContainer, error.message);
        }
    }
    
    static renderHotelCard(hotel) {
        const stars = hotel.star_rating ? '⭐'.repeat(Math.floor(hotel.star_rating)) : '';
        
        return `
            <div class="col-md-6 col-lg-4 mb-4 fade-in">
                <div class="card hotel-card" onclick="Hotels.viewHotel(${hotel.hotel_id})">
                    <div class="hotel-image">
                        <i class="bi bi-building"></i>
                    </div>
                    <div class="card-body">
                        <h5 class="card-title">${hotel.name}</h5>
                        <p class="card-text">
                            <i class="bi bi-geo-alt"></i> ${hotel.city}, ${hotel.country}
                        </p>
                        <p class="card-text">
                            <small class="text-muted">${hotel.address}</small>
                        </p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="stars">${stars}</div>
                            <button class="btn btn-primary btn-sm">
                                Подробнее <i class="bi bi-arrow-right"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    static async viewHotel(hotelId) {
        const container = document.getElementById('app-content');
        showSpinner(container);
        
        try {
            const hotel = await API.getHotel(hotelId);
            
            const stars = hotel.star_rating ? '⭐'.repeat(Math.floor(hotel.star_rating)) : '';
            
            container.innerHTML = `
                <div class="row">
                    <div class="col-12">
                        <button class="btn btn-link mb-3" onclick="App.loadPage('hotels')">
                            <i class="bi bi-arrow-left"></i> Назад к списку
                        </button>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="hotel-image" style="height: 300px;">
                                <i class="bi bi-building"></i>
                            </div>
                            <div class="card-body">
                                <h2 class="card-title">${hotel.name}</h2>
                                <div class="stars mb-3">${stars}</div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><i class="bi bi-geo-alt"></i> <strong>Адрес:</strong> ${hotel.address}</p>
                                        <p><i class="bi bi-pin-map"></i> <strong>Город:</strong> ${hotel.city}, ${hotel.country}</p>
                                        <p><i class="bi bi-telephone"></i> <strong>Телефон:</strong> ${hotel.phone || 'Не указан'}</p>
                                        <p><i class="bi bi-envelope"></i> <strong>Email:</strong> ${hotel.email || 'Не указан'}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <p>${hotel.description || 'Описание отсутствует'}</p>
                                    </div>
                                </div>
                                
                                <hr>
                                
                                <h4 class="mb-3">Доступные номера</h4>
                                <div id="hotel-rooms">
                                    <div class="text-center">
                                        <div class="spinner-border" role="status"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            // Загрузить номера отеля (когда API будет готов)
            // await this.loadHotelRooms(hotelId);
            
        } catch (error) {
            showError(container, error.message);
        }
    }
    
    static showAddHotelModal() {
        // TODO: Реализовать модальное окно добавления отеля
        alert('Функция добавления отеля в разработке');
    }
}
