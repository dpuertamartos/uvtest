from app.services.calculate import calculate_sum


class TestLogic:
    def test_calculate_sum(self):
        assert calculate_sum(1, 2) == 3
