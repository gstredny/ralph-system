#!/bin/bash
echo "═══════════════════════════════════════"
echo "  Ralph Validation Check"
echo "═══════════════════════════════════════"

# Docker check
echo "🐳 Docker status:"
docker-compose ps 2>/dev/null || echo "No docker-compose found"

# Health check
echo ""
echo "🏥 Health check:"
curl -s http://localhost:8000/health || echo "Backend not responding"

# Test suite
echo ""
echo "🧪 Running tests:"
if [ -d "backend" ]; then
    cd backend && pytest --tb=line -q 2>&1 | tail -20
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest --tb=line -q 2>&1 | tail -20
else
    echo "No test config found"
fi

echo ""
echo "═══════════════════════════════════════"
