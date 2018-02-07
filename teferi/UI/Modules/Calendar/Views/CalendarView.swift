import UIKit

protocol CalendarDelegate
{
    func didChange(month: Date)
    func didSelect(day: Date)
}

class CalendarView: UICollectionView
{
    private var startDate: Date!
    private var endDate: Date!
    private var numberOfMonths: Int = 0
    
    private var viewModel: CalendarViewModel!
    
    var calendarDelegate: CalendarDelegate?
    
    var selectedDate: Date? = nil
    
    fileprivate(set) var currentMonth: Date? = nil
    
    fileprivate lazy var calendar: Calendar = {
        return NSCalendar.current
    }()
    
    func setup(startDate: Date = Date().add(months: -12 * 4), endDate: Date = Date(), viewModel: CalendarViewModel)
    {
        guard startDate < endDate else {
            fatalError("Calendar Error: startDate has to be < endDate")
        }
        self.startDate = startDate
        self.endDate = endDate
        self.viewModel = viewModel
        
        if let monthsBetweenDates = calendar.dateComponents([.month], from: startDate.firstDateOfMonth, to: endDate.firstDateOfMonth).month {
            numberOfMonths = monthsBetweenDates + 1
        } else {
            numberOfMonths = 0
        }
        
        let layout = collectionViewLayout as! HorizontalFlowLayout
        let itemWidth = Int((self.bounds.width - (contentInset.left + contentInset.right)) / 7)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        self.setCollectionViewLayout(layout, animated: false)
        
        dataSource = self
        delegate = self
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    func setCurrentMonth(date: Date)
    {
        guard date.firstDateOfMonth >= startDate.firstDateOfMonth && date.firstDateOfMonth <= endDate.firstDateOfMonth else {
            fatalError("Current month must be startMonth <= currentMonth <= endMonth")
        }
        let animate = currentMonth != nil
        scroll(to: date.firstDateOfMonth, animated: animate)
    }
    
    func setSelectedDate(date: Date)
    {
        selectedDate = date
        setCurrentMonth(date: date.firstDateOfMonth)
        
        if let indexPath = indexPath(forDate: date) {
            selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
        }
    }
    
    func goToPreviousMonth()
    {
        guard let oldCurrentMonth = currentMonth else { return }
        setCurrentMonth(date: oldCurrentMonth.add(months: -1).firstDateOfMonth)
    }
    
    func goToNextMonth()
    {
        guard let oldCurrentMonth = currentMonth else { return }
        setCurrentMonth(date: oldCurrentMonth.add(months: 1).firstDateOfMonth)
    }

    fileprivate func date(forIndexPath indexPath: IndexPath) -> Date?
    {
        let firstOfMonth = startDate.firstDateOfMonth.add(months: indexPath.section).firstDateOfMonth
        let weekDayMonthStart = firstOfMonth.dayOfWeek == 0 ? 7 : firstOfMonth.dayOfWeek
        let offset = indexPath.row - weekDayMonthStart + 1
        
        let date = firstOfMonth.add(days: offset)
        guard date.month == firstOfMonth.month else {
            return nil // Date belongs to another month, don't show it
        }
        
        return date
    }
    
    private func indexPath(forDate date: Date) -> IndexPath?
    {
        guard let monthsSinceStart = calendar.dateComponents([.month], from: startDate.firstDateOfMonth, to: date.firstDateOfMonth).month else {
            return nil
        }
        
        let weekDayMonthStart = date.firstDateOfMonth.dayOfWeek == 0 ? 7 : date.firstDateOfMonth.dayOfWeek
        let offset = weekDayMonthStart - 1
        
        return IndexPath(row: date.day - 1 + offset, section: monthsSinceStart)
    }
    
    private func scroll(to month: Date, animated: Bool)
    {
        guard let monthsBetweenDates = calendar.dateComponents([.month], from: startDate.firstDateOfMonth, to: month).month else {
                return
        }

        let newOffset = CGPoint(
            x: CGFloat(monthsBetweenDates) * bounds.width,
            y: contentOffset.y
        )
        
        setContentOffset(newOffset, animated: animated)
        if !animated {
            currentMonth = month
            calendarDelegate?.didChange(month: currentMonth!)
        }
    }
}

extension CalendarView: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return numberOfMonths
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 6 * 7 // Max weeks a month can span is 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        let cellDate = date(forIndexPath: indexPath)
        var cellEnabled = false
        if let cellDate = cellDate?.ignoreTimeComponents() {
            cellEnabled = cellDate >= startDate.ignoreTimeComponents() && cellDate <= endDate.ignoreTimeComponents()
        }
        cell.configure(date: cellDate, enabled: cellEnabled, activities: viewModel.getActivities(forDate: cellDate))

        return cell
    }
}

extension CalendarView: UICollectionViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let page = Int(round(scrollView.contentOffset.x / bounds.width))
        let newMonth = startDate.firstDateOfMonth.add(months: page).firstDateOfMonth
        if currentMonth != newMonth {
            currentMonth = newMonth
            calendarDelegate?.didChange(month: currentMonth!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        guard let date = date(forIndexPath: indexPath), selectedDate != date else { return }        
        calendarDelegate?.didSelect(day: date)
    }
}
