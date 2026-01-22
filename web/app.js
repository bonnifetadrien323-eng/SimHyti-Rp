const overlay = document.getElementById('overlay');
const categoryList = document.getElementById('categoryList');
const pageTitle = document.getElementById('pageTitle');
const pageSubtitle = document.getElementById('pageSubtitle');
const pageContent = document.getElementById('pageContent');
const closeButton = document.getElementById('close');
const logo = document.getElementById('logo');
const title = document.getElementById('title');
const categoriesLabel = document.getElementById('categoriesLabel');
const adminToggle = document.getElementById('adminToggle');
const adminPanel = document.getElementById('adminPanel');
const adminClose = document.getElementById('adminClose');
const adminTitle = document.getElementById('adminTitle');
const adminCategories = document.getElementById('adminCategories');
const adminPages = document.getElementById('adminPages');
const adminPoints = document.getElementById('adminPoints');

const categoryForm = document.getElementById('categoryForm');
const categoryId = document.getElementById('categoryId');
const categoryLabel = document.getElementById('categoryLabel');
const categorySort = document.getElementById('categorySort');

const pageForm = document.getElementById('pageForm');
const pageId = document.getElementById('pageId');
const pageCategory = document.getElementById('pageCategory');
const pageTitleInput = document.getElementById('pageTitleInput');
const pageType = document.getElementById('pageType');
const pageSort = document.getElementById('pageSort');
const pageEnabled = document.getElementById('pageEnabled');
const pageContentInput = document.getElementById('pageContentInput');

const pointForm = document.getElementById('pointForm');
const pointId = document.getElementById('pointId');
const pointPage = document.getElementById('pointPage');
const pointLabel = document.getElementById('pointLabel');
const pointX = document.getElementById('pointX');
const pointY = document.getElementById('pointY');
const pointZ = document.getElementById('pointZ');

let guidebookData = { categories: [], pages: [], points: [] };
let strings = {};

function postNui(action, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).then((res) => res.json());
}

function renderCategories() {
    categoryList.innerHTML = '';
    guidebookData.categories.forEach((category, index) => {
        const item = document.createElement('li');
        item.textContent = category.label;
        if (index === 0) {
            item.classList.add('active');
        }
        item.addEventListener('click', () => {
            document.querySelectorAll('#categoryList li').forEach((el) => el.classList.remove('active'));
            item.classList.add('active');
            renderFirstPage(category.id);
        });
        categoryList.appendChild(item);
    });
}

function renderFirstPage(categoryId) {
    const page = guidebookData.pages.find((entry) => entry.category_id === categoryId && entry.enabled === 1) || guidebookData.pages[0];
    if (page) {
        renderPage(page);
    }
}

function renderPage(page) {
    pageTitle.textContent = page.title;
    pageSubtitle.textContent = page.page_type === 'shortcuts' ? 'Raccourcis' : '';
    pageContent.innerHTML = '';

    if (page.page_type === 'shortcuts') {
        let shortcuts = [];
        try {
            shortcuts = JSON.parse(page.content || '[]');
        } catch (error) {
            shortcuts = [];
        }
        const grid = document.createElement('div');
        grid.className = 'shortcut-grid';
        shortcuts.forEach((shortcut) => {
            const card = document.createElement('div');
            card.className = 'shortcut-card';
            card.innerHTML = `
                <div class="shortcut-key">${shortcut.key || ''}</div>
                <strong>${shortcut.label || ''}</strong>
                <span>${shortcut.description || ''}</span>
            `;
            grid.appendChild(card);
        });
        pageContent.appendChild(grid);
    } else {
        const paragraph = document.createElement('p');
        paragraph.textContent = page.content || '';
        pageContent.appendChild(paragraph);
    }

    const pagePoints = guidebookData.points.filter((point) => point.page_id === page.id);
    if (pagePoints.length) {
        const wrapper = document.createElement('div');
        wrapper.className = 'points';
        pagePoints.forEach((point) => {
            const pill = document.createElement('div');
            pill.className = 'point';
            pill.textContent = point.label;
            pill.addEventListener('click', () => {
                postNui('setWaypoint', { x: point.x, y: point.y, z: point.z });
            });
            wrapper.appendChild(pill);
        });
        pageContent.appendChild(wrapper);
    }
}

function renderAdmin() {
    adminCategories.innerHTML = '';
    adminPages.innerHTML = '';
    adminPoints.innerHTML = '';

    guidebookData.categories.forEach((category) => {
        const item = document.createElement('div');
        item.className = 'admin-item';
        item.innerHTML = `<span>${category.label}</span>`;

        const actions = document.createElement('div');
        const edit = document.createElement('button');
        edit.textContent = '✎';
        edit.addEventListener('click', () => {
            categoryId.value = category.id;
            categoryLabel.value = category.label;
            categorySort.value = category.sort_order || 0;
        });

        const remove = document.createElement('button');
        remove.textContent = '🗑';
        remove.addEventListener('click', () => {
            postNui('admin:deleteItem', { type: 'category', id: category.id }).then(refreshData);
        });

        actions.append(edit, remove);
        item.appendChild(actions);
        adminCategories.appendChild(item);
    });

    guidebookData.pages.forEach((page) => {
        const item = document.createElement('div');
        item.className = 'admin-item';
        item.innerHTML = `<span>${page.title}</span>`;

        const actions = document.createElement('div');
        const edit = document.createElement('button');
        edit.textContent = '✎';
        edit.addEventListener('click', () => {
            pageId.value = page.id;
            pageCategory.value = page.category_id;
            pageTitleInput.value = page.title;
            pageType.value = page.page_type || 'text';
            pageSort.value = page.sort_order || 0;
            pageEnabled.value = page.enabled ? '1' : '0';
            pageContentInput.value = page.content || '';
        });

        const remove = document.createElement('button');
        remove.textContent = '🗑';
        remove.addEventListener('click', () => {
            postNui('admin:deleteItem', { type: 'page', id: page.id }).then(refreshData);
        });

        actions.append(edit, remove);
        item.appendChild(actions);
        adminPages.appendChild(item);
    });

    guidebookData.points.forEach((point) => {
        const item = document.createElement('div');
        item.className = 'admin-item';
        item.innerHTML = `<span>${point.label}</span>`;

        const actions = document.createElement('div');
        const edit = document.createElement('button');
        edit.textContent = '✎';
        edit.addEventListener('click', () => {
            pointId.value = point.id;
            pointPage.value = point.page_id;
            pointLabel.value = point.label;
            pointX.value = point.x;
            pointY.value = point.y;
            pointZ.value = point.z;
        });

        const remove = document.createElement('button');
        remove.textContent = '🗑';
        remove.addEventListener('click', () => {
            postNui('admin:deleteItem', { type: 'point', id: point.id }).then(refreshData);
        });

        actions.append(edit, remove);
        item.appendChild(actions);
        adminPoints.appendChild(item);
    });

    pageCategory.innerHTML = '';
    guidebookData.categories.forEach((category) => {
        const option = document.createElement('option');
        option.value = category.id;
        option.textContent = category.label;
        pageCategory.appendChild(option);
    });

    pointPage.innerHTML = '';
    guidebookData.pages.forEach((page) => {
        const option = document.createElement('option');
        option.value = page.id;
        option.textContent = page.title;
        pointPage.appendChild(option);
    });
}

function refreshData() {
    return postNui('refresh').then((payload) => {
        guidebookData = payload;
        renderCategories();
        renderFirstPage(payload.categories[0]?.id);
        if (payload.isAdmin) {
            renderAdmin();
        }
    });
}

window.addEventListener('message', (event) => {
    if (event.data.action === 'open') {
        guidebookData = event.data.data;
        strings = event.data.strings || {};
        title.textContent = strings.title || 'Guidebook';
        categoriesLabel.textContent = strings.categories || 'Catégories';
        adminTitle.textContent = strings.admin || 'Administration';
        logo.src = event.data.data.logoUrl || '';
        overlay.hidden = false;
        adminToggle.hidden = !event.data.data.isAdmin;
        renderCategories();
        renderFirstPage(event.data.data.categories[0]?.id);
        if (event.data.data.isAdmin) {
            renderAdmin();
        }
    }
});

closeButton.addEventListener('click', () => {
    overlay.hidden = true;
    adminPanel.hidden = true;
    postNui('close');
});

adminToggle.addEventListener('click', () => {
    adminPanel.hidden = !adminPanel.hidden;
});

adminClose.addEventListener('click', () => {
    adminPanel.hidden = true;
});

categoryForm.addEventListener('submit', (event) => {
    event.preventDefault();
    postNui('admin:saveCategory', {
        id: categoryId.value || null,
        label: categoryLabel.value,
        sort_order: Number(categorySort.value || 0)
    }).then(() => {
        categoryForm.reset();
        categoryId.value = '';
        refreshData();
    });
});

pageForm.addEventListener('submit', (event) => {
    event.preventDefault();
    let content = pageContentInput.value;
    if (pageType.value === 'shortcuts') {
        try {
            content = JSON.parse(pageContentInput.value || '[]');
        } catch (error) {
            return;
        }
    }
    postNui('admin:savePage', {
        id: pageId.value || null,
        category_id: Number(pageCategory.value),
        title: pageTitleInput.value,
        page_type: pageType.value,
        sort_order: Number(pageSort.value || 0),
        enabled: pageEnabled.value === '1',
        content: content
    }).then(() => {
        pageForm.reset();
        pageId.value = '';
        refreshData();
    });
});

pointForm.addEventListener('submit', (event) => {
    event.preventDefault();
    postNui('admin:savePoint', {
        id: pointId.value || null,
        page_id: Number(pointPage.value),
        label: pointLabel.value,
        x: Number(pointX.value),
        y: Number(pointY.value),
        z: Number(pointZ.value)
    }).then(() => {
        pointForm.reset();
        pointId.value = '';
        refreshData();
    });
});
